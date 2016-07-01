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
#  is_strict         :boolean          default(FALSE), not null
#

class Trade::ValidationRule < ActiveRecord::Base
  attr_accessible :column_names, :run_order, :is_primary, :scope, :is_strict
  include PgArrayParser
  serialize :scope, ActiveRecord::Coders::NestedHstore

  # returns column names as in the shipments table, based on the
  # list of column_names in sandbox
  def shipments_columns
    column_names.map do |column|
      case column
      when 'taxon_name'
        'taxon_concept_id'
      when 'appendix'
        column
      when 'year'
        column
      when /(.+)_code$/
        $1 + '_id'
      when /(.+)_id$/
        column
      else
        column + '_id'
      end
    end
  end

  def column_names
    parse_pg_array(read_attribute(:column_names))
  end

  def column_names=(ary)
    write_attribute(:column_names, '{' + ary.join(',') + '}')
  end

  def validation_errors(annual_report_upload)
    matching_records = matching_records(annual_report_upload.sandbox.table_name)
    error_count = matching_records.length
    if error_count > 0
      [
        Trade::ValidationError.new(
          :error_message => error_message,
          :annual_report_upload_id => annual_report_upload.id,
          :validation_rule_id => self.id,
          :error_count => error_count,
          :matching_records_ids => matching_records.map(&:id),
          :is_primary => self.is_primary
        )
      ]
    else
      []
    end
  end

  def validation_errors_for_shipment(shipment)
    return nil if is_primary #primary validations are handled by AR
    #raise "Not implemented"
    'shipment validation not implemented'
  end

  # Sanitizes column names provided within the scope attribute.
  # Example of a scope definition:
  # :scope => {
  #   :source_code => { :inclusion => ['W'] },
  #   :country_of_origin => { :blank => true },
  #   :exporter => { :exclusion => 'XX' }
  # }
  # This method is public, because it is exposed in the serializer
  def sanitized_sandbox_scope
    res = {}
    scope && scope.each do |scope_column, scope_def|
      if (
        Trade::SandboxTemplate.column_names +
        ['point_of_view', 'importer', 'exporter', 'rank']
      ).include? scope_column
        res[scope_column] = scope_def
      end
    end
    res
  end

  private

  # If sandbox scope was :source_code => { :inclusion => ['W'] }, shipments
  # scope needs to be :source_code => { :inclusion => [ID of W] }
  def sanitized_shipments_scope
    res = {}
    sanitized_sandbox_scope.each do |scope_column, scope_def|
      case scope_column
      when 'taxon_name', 'rank'
        false
      when 'appendix', 'year'
        res[scope_column] = scope_def
      when 'exporter', 'importer', 'country_of_origin'
        tmp_def = {}
        (scope_def.keys & ['inclusion', 'exclusion']).each do |k|
          tmp_def[k] = scope_def[k].map { |value| GeoEntity.find_by_iso_code2(value).id }
        end
        tmp_def['blank'] = scope_def['blank'] if scope_def.key?('blank')
        res[scope_column + '_id'] = tmp_def
      when /(.+)_code$/
        tmp_def = {}
        (scope_def.keys & ['inclusion', 'exclusion']).each do |k|
          tmp_def[k] = scope_def[k].map { |value| TradeCode.find_by_type_and_code($1.capitalize, value).id }
        end
        tmp_def['blank'] = scope_def['blank'] if scope_def.key?('blank')
        res[$1 + '_id'] = tmp_def
      else
        tmp_def = {}
        scope_def.keys & ['inclusion', 'exclusion', 'blank'].each do |k|
          tmp_def[k] = scope_def[k]
        end
        res[scope_column + '_id'] = tmp_def
      end
    end
    res
  end

  def shipment_in_scope?(shipment)
    shipment_in_scope = true
    # check if shipment is in scope of this validation
    sanitized_shipments_scope.each do |scope_column, scope_def|
      value = shipment.send(scope_column)
      if scope_def['inclusion']
        shipment_in_scope = false unless scope_def['inclusion'].include?(value)
      end
      if scope_def['exclusion']
        shipment_in_scope = false if scope_def['exclusion'].include?(value)
      end
      if scope_def['blank']
        shipment_in_scope = false unless shipment.send(scope_column).blank?
      end
    end
    # make sure the validated fields are not blank
    required_shipments_columns.each do |column|
      shipment_in_scope = false if shipment.send(column).blank?
    end
    shipment_in_scope
  end

  def required_column_names
    if is_strict
      column_names
    else
      column_names & [
        'taxon_concept_id', 'taxon_name', 'appendix', 'year', 'term_code',
        'trading_partner', 'importer', 'exporter', 'reporter_type', 'quantity'
      ]
    end
  end

  def required_shipments_columns
    if is_strict
      shipments_columns
    else
      shipments_columns & [
        'taxon_concept_id', 'appendix', 'year', 'term_id',
        'exporter_id', 'importer_id', 'reporter_type', 'quantity'
      ]
    end
  end

end
