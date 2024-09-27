# == Schema Information
#
# Table name: trade_validation_rules
#
#  id                :integer          not null, primary key
#  column_names      :string(255)      is an Array
#  format_re         :string(255)
#  is_primary        :boolean          default(TRUE), not null
#  is_strict         :boolean          default(FALSE), not null
#  run_order         :integer          not null
#  scope             :hstore
#  type              :string(255)      not null
#  valid_values_view :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Trade::InclusionValidationRule < Trade::ValidationRule
  # Only created by seed.
  # attr_accessible :valid_values_view

  def matching_records_for_aru_and_error(annual_report_upload, validation_error)
    # The format of validation_error.matching_criteria seems to vary - sometimes
    # it's a string, whereas under rspec it's an object.
    matching_criteria_json =
      if validation_error.matching_criteria.is_a? String
        validation_error.matching_criteria
      else
        validation_error.matching_criteria.to_json
      end

    @query = matching_records(annual_report_upload).where(
      "#{Arel::Nodes.build_quoted(matching_criteria_json).to_sql}::JSONB @> (#{jsonb_matching_criteria_for_comparison})::JSONB"
    )
  end

  def error_message(values_hash = nil)
    scope_info = sanitized_sandbox_scope.map do |scope_column, scope_def|
      tmp = []

      if scope_def['inclusion']
        tmp << "#{scope_column} = #{scope_def['inclusion'].join(', ')}"
      end

      if scope_def['exclusion']
        tmp << "#{scope_column} != #{scope_def['exclusion'].join(', ')}"
      end

      if scope_def['blank']
        tmp << "#{scope_column} is empty"
      end

      tmp.join(' and ')
    end.compact.join(', ')

    info = column_names_for_matching.each_with_index.map do |cn|
      # for taxon concept validations output human readable taxon_name
      if cn == 'taxon_concept_id'
        "taxon_name #{values_hash && (values_hash['accepted_taxon_name'].presence || '[BLANK]')}"
      else
        "#{cn} #{values_hash && (values_hash[cn].presence || '[BLANK]')}"
      end
    end.join(' with ')

    info = "#{info} (#{scope_info})" if scope_info.present?
    info + ' is invalid'
  end

  def refresh_errors_if_needed(annual_report_upload)
    return true unless refresh_needed?(annual_report_upload)

    errors_to_destroy = validation_errors.to_a

    matching_records_grouped(annual_report_upload).map do |mr|
      values_hash = matching_record_to_matching_hash(mr)
      values_hash_for_display = column_names_for_display.index_with { |cn| mr.send(cn) }

      matching_criteria_jsonb = jsonb_matching_criteria_for_comparison(
        values_hash
      )

      # if existing_record exists, we will update, rather than create
      existing_record = validation_errors_for_aru(annual_report_upload).where(
        "matching_criteria @> (#{matching_criteria_jsonb})::JSONB"
      ).first

      update_or_create_error_record(
        annual_report_upload,
        existing_record,
        mr.error_count.to_i,
        error_message(values_hash_for_display),
        values_hash
      )

      if existing_record
        errors_to_destroy.reject! { |e| e.id == existing_record.id }
      end
    end

    errors_to_destroy.each(&:destroy)
  end

  def validation_errors_for_shipment(shipment)
    return nil unless shipment_in_scope?(shipment)

    # if it is, check if it has a match in valid values view
    v = Arel::Table.new(valid_values_view)
    arel_nodes = shipments_columns.map { |c| v[c].eq(shipment.send(c)) }
    return nil if Trade::Shipment.find_by_sql(v.project(Arel.star).where(arel_nodes.inject(&:and))).any?

    error_message
  end

private

  def column_names_for_matching
    column_names
  end

  def column_names_for_display_with_custom_table_name(table_name:)
    column_names_for_display.map { |column_name| Arel::Nodes::SqlLiteral.new("#{table_name}.#{column_name}") }
  end

  def column_names_for_display
    if column_names.include? ('taxon_concept_id')
      column_names << 'accepted_taxon_name'
    else
      column_names
    end
  end

  ##
  # Returns a Hash whose keys are all column_names
  # and whose values are stringified values of those columns
  # so that there are no type mismatch issues for when we later query
  # matching_criteria using jsonb_matching_criteria_for_comparison
  def matching_record_to_matching_hash(mr)
    (
      column_names.map do |column_name|
        column_value = mr.send(column_name)
        if column_value.nil?
          [ column_name, '' ]
        else
          [ column_name, column_value.to_s ]
        end
      end
    ).to_h
  end

  ##
  # Returns a string which can be interpolated into an SQL statement,
  # and used in an expression (which should be coerced to type JSONB),
  # checking matching_criteria.
  #
  # The string will be at minimum "'{' || ... || '}'" - i.e. it is a
  # concatenation of sql strings.
  def jsonb_matching_criteria_for_comparison(values_hash = nil)
    jsonb_keys_and_values = column_names.map do |c|
      value_present = values_hash && values_hash.key?(c)
      value = value_present && values_hash[c]
      column_reference = c.to_s
      value_or_column_reference_quoted =
        if value_present
          Arel::Nodes.build_quoted(
            value.to_s.to_json
          ).to_sql
        else
          <<-EOT
            '"' || COALESCE("#{column_reference}"::TEXT, '') || '"'
          EOT
        end
      <<-EOT
        '"' || '#{c}' || '": ' || #{value_or_column_reference_quoted}
      EOT
    end.join("|| ', ' ||")

    "'{' || #{jsonb_keys_and_values} || '}'"
  end

  # Returns matching records grouped by column_names to return the count of
  # specific errors and ids of matching records
  def matching_records_grouped(annual_report_upload)
    table_name = annual_report_upload.sandbox.table_name

    Trade::SandboxTemplate.select(
      # IMPORTANT NOTE:
      # After upgrading to Rails 4.1 (Arel 5.0.1), Rails injects the table name in front of column names.
      # For example: From `SELECT taxon_concept_id FROM...` to `SELECT trade_sandbox_template.taxon_concept_id FROM...`.
      # There is nothing inherently wrong with Rails, but it doesn't work well with this project, which involves many
      # highly customized low-level SQL queries.
      # In this case the FROM clause aliases a name which does not have a model.
      # A quick and temporary solution for now is to manually inject the correct table name ourselves.
      column_names_for_display_with_custom_table_name(
        table_name: 'matching_records'
      ) + [
        'COUNT(*) AS error_count',
        'ARRAY_AGG(id) AS matching_records_ids'
      ]
    ).from(
      Arel.sql("(#{matching_records_arel(table_name).to_sql}) AS matching_records")
    ).group(
      column_names_for_display_with_custom_table_name(table_name: 'matching_records')
    ).having(
      required_column_names.map { |cn| "#{cn} IS NOT NULL" }.join(' AND ')
    )
  end

  def matching_records(annual_report_upload)
    table_name = annual_report_upload.sandbox.table_name
    sandbox_klass = Trade::SandboxTemplate.ar_klass(table_name)
    sandbox_klass.select(
      Arel.star
    ).from(
      Arel.sql("(#{matching_records_arel(table_name).to_sql}) AS matching_records")
    )
  end

  # Returns records from sandbox where values in column_names are not null
  # and optionally filtered down by specified scope
  # Pass Arel::Table
  def scoped_records_arel(s)
    not_null_nodes =
      required_column_names.map do |c|
        s[c].not_eq(nil)
      end
    not_null_conds = not_null_nodes.shift
    not_null_nodes.each { |n| not_null_conds = not_null_conds.and(n) }
    result = s.project(Arel.star).where(not_null_conds)
    scope_nodes = sanitized_sandbox_scope.map do |scope_column, scope_def|
      tmp = []

      if scope_def['inclusion']
        inclusion_nodes = scope_def['inclusion'].map { |value| s[scope_column].eq(value) }
        tmp << inclusion_nodes.inject(&:or)
      end

      if scope_def['exclusion']
        exclusion_nodes = scope_def['exclusion'].map { |value| s[scope_column].not_eq(value) }
        tmp << exclusion_nodes.inject(&:or)
      end

      if scope_def['blank']
        tmp << s[scope_column].eq(nil)
      end

      tmp
    end.flatten

    scope_conds = scope_nodes.inject(&:and)
    result = result.where(scope_conds) if scope_conds

    result
  end

  # Returns records from sandbox where values in column_names are not included
  # in valid_values_view.
  # The valid_values_view should have the same column names and data types as
  # the sandbox columns specified in column_names.
  def matching_records_arel(table_name)
    table_s = Arel::Table.new("#{table_name}_view")
    table_v = Arel::Table.new(valid_values_view)
    arel_nodes =
      column_names_for_matching.map do |column_name|
        if required_column_names.include?(column_name)
          table_v[column_name].eq(table_s[column_name])
        else
          # if optional, check if NULL is allowed for this particular combination
          # e.g. unit code can be blank only if paired with certain terms
          table_v[column_name].eq(table_s[column_name]).or(table_v[column_name].eq(nil).and(table_s[column_name].eq(nil)))
        end
      end

    valid_values = table_s.project(table_s[Arel.star]).join(table_v).on(arel_nodes.inject(&:and))

    scoped_records_arel(table_s).except(valid_values)
  end
end
