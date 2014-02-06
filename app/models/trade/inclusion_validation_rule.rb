# == Schema Information
#
# Table name: trade_validation_rules
#
#  id                :integer          not null, primary key
#  valid_values_view :string(255)
#  type              :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  format_re         :string(255)
#  run_order         :integer          not null
#  column_names      :string(255)
#  is_primary        :boolean          default(TRUE), not null
#  scope             :hstore
#

class Trade::InclusionValidationRule < Trade::ValidationRule
  attr_accessible :valid_values_view

  def error_message(values_hash = nil)
    scope_info = sanitized_scope.map do |scope_column, scope_value|
      "#{scope_column} = #{scope_value}"
    end.compact.join(', ')
    info = column_names_for_matching.each_with_index.map do |cn|
      # for taxon concept validations output human readable species_name
      if cn == 'taxon_concept_id'
        "species_name #{values_hash && (values_hash['species_name'].blank? ? '[BLANK]' : values_hash['species_name'])}"
      else
        "#{cn} #{values_hash && (values_hash[cn].blank? ? '[BLANK]' : values_hash[cn])}"
      end
    end.join(" with ")
    info = "#{info} (#{scope_info})" unless scope_info.blank?
    info + ' is invalid'
  end

  def validation_errors(annual_report_upload)
    matching_records_grouped(annual_report_upload.sandbox.table_name).map do |mr|
      error_selector = error_selector(mr, annual_report_upload.point_of_view)
      values_hash = Hash[column_names_for_display.map{ |cn| [cn, mr.send(cn)] }]
      Trade::ValidationError.new(
          :error_message => error_message(values_hash),
          :annual_report_upload_id => annual_report_upload.id,
          :validation_rule_id => self.id,
          :error_count => mr.error_count,
          :error_selector => error_selector,
          :matching_records_ids => parse_pg_array(mr.matching_records_ids),
          :is_primary => self.is_primary
      )
    end
  end

  def validation_errors_for_shipment(shipment)
    shipment_in_scope = true
    # check if shipment is in scope of this validation
    shipments_scope.each do |scope_column, scope_value|
      shipment_in_scope = false if shipment.send(scope_column) != scope_value
    end
    # make sure the validated fields are not blank
    required_shipments_columns.each do |column|
      shipment_in_scope = false if shipment.send(column).blank?
    end
    return nil unless shipment_in_scope
    # if it is, check if it has a match in valid values view
    v = Arel::Table.new(valid_values_view)
    arel_nodes = shipments_columns.map { |c| v[c].eq(shipment.send(c)) }
    conditions = arel_nodes.shift
    arel_nodes.each{ |n| conditions = conditions.and(n) }
    return nil if Trade::Shipment.find_by_sql(v.project('*').where(conditions)).any?
    error_message
  end

  private

  def column_names_for_matching
    column_names
  end

  def column_names_for_display
    if column_names.include? ('taxon_concept_id')
      column_names << 'species_name'
    else
      column_names
    end
  end

  # Returns a hash with column values to be used to select invalid rows.
  # e.g.
  # {
  #    :species_name => 'Loxodonta africana',
  #    :term_code => 'CAV'
  #
  # }
  # Expects a single grouped matching record.
  def error_selector(matching_record, point_of_view)
    res = {}
    column_names.each do |cn|
      if cn == 'exporter' && point_of_view == 'I'
        res['trading_partner'] = matching_record.send(cn)
      elsif cn == 'importer' && point_of_view == 'E'
        res['trading_partner'] = matching_record.send(cn)
      elsif !['importer', 'exporter'].include?(cn)
        res[cn] = matching_record.send(cn)
      end
    end
    sanitized_scope.map do |scn, val|
      res[scn] = val
    end
    res
  end

  # Returns matching records grouped by column_names to return the count of
  # specific errors and ids of matching records
  def matching_records_grouped(table_name)
    Trade::SandboxTemplate.
    select(
      column_names_for_display +
      ['COUNT(*) AS error_count', 'ARRAY_AGG(id) AS matching_records_ids']
    ).from(Arel.sql("(#{matching_records_arel(table_name).to_sql}) AS matching_records")).
    group(column_names_for_display).having(
      required_column_names.map{ |cn| "#{cn} IS NOT NULL"}.join(' AND ')
    )
  end

  # Returns records from sandbox where values in column_names are not null
  # and optionally filtered down by specified scope
  # Pass Arel::Table
  def scoped_records_arel(s)
    not_null_nodes = required_column_names.map do |c|
      s[c].not_eq(nil)
    end
    not_null_conds = not_null_nodes.shift
    not_null_nodes.each{ |n| not_null_conds = not_null_conds.and(n) }
    result = s.project('*').where(not_null_conds)
    scope_nodes = sanitized_scope.map do |scope_column, scope_value|
      s[scope_column].eq(scope_value)
    end
    scope_conds = scope_nodes.shift
    scope_nodes.each{ |n| scope_conds = scope_conds.and(n) }
    result = result.where(scope_conds) if scope_conds

    result
  end

  # Returns records from sandbox where values in column_names are not included
  # in valid_values_view.
  # The valid_values_view should have the same column names and data types as
  # the sandbox columns specified in column_names.
  def matching_records_arel(table_name)
    s = Arel::Table.new("#{table_name}_view")
    v = Arel::Table.new(valid_values_view)
    arel_nodes = column_names_for_matching.map do |c|
      if required_column_names.include? c
        v[c].eq(s[c])
      else
        # if optional, check if NULL is allowed for this particular combination
        # e.g. unit code can be blank only if paired with certain terms
        v[c].eq(s[c]).or(v[c].eq(nil).and(s[c].eq(nil)))
      end
    end
    join_conditions = arel_nodes.shift
    arel_nodes.each{ |n| join_conditions = join_conditions.and(n) }
    valid_values = s.project(s['*']).join(v).on(join_conditions)
    scoped_records_arel(s).except(valid_values)
  end

end
