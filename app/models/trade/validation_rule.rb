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

class Trade::ValidationRule < ActiveRecord::Base
  attr_accessible :column_names, :run_order, :is_primary, :scope
  include PgArrayParser
  serialize :scope, ActiveRecord::Coders::Hstore

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
          :error_selector => error_selector(matching_records),
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

  # Sanitizes column names provided within the scope attribute
  # Also replaces attr_blank => true with attr => nil
  def sanitized_scope
    res = {}
    scope && scope.each do |scope_column, scope_value|
      scope_column =~ /(.+?)(_blank)?$/
      scope_column = $1
      scope_value = nil unless $2.nil? #if _blank, then check for null
      if (
        Trade::SandboxTemplate.column_names +
        ['point_of_view', 'importer', 'exporter']
      ).include? scope_column
        res[scope_column] = scope_value
      end
    end
    res
  end

  private

  def required_column_names
    column_names & ['taxon_concept_id', 'taxon_name', 'appendix', 'year', 'term_code',
      'trading_partner', 'importer', 'exporter', 'reporter_type', 'quantity'
    ]
  end

  def required_shipments_columns
    shipments_columns & ['taxon_concept_id', 'appendix', 'year', 'term_id',
      'exporter_id', 'importer_id', 'reporter_type', 'quantity'
    ]
  end

  # so if sandbox scope was {source_code = W}, shipments
  # scope needs to be {source_id = [id of W]}
  def shipments_scope
    res = {}
    sanitized_scope.each do |scope_column, scope_value|
      case scope_column
      when 'taxon_name'
        false #basically no point scoping rules on taxon id
      when 'appendix'
        res[scope_column] = scope_value
      when 'year'
        res[scope_column] = scope_value
      when /(.+)_code$/
        res[$1 + '_id'] = TradeCode.find_by_type_and_code($1.capitalize, scope_value).id
      else
        res[scope_column + '_id'] = scope_value
      end
    end
    res
  end

  # Returns a hash with column values to be used to select invalid rows.
  # For most primary validations this will be a pair
  # of validated field => array of invalid values.
  # e.g.
  # {
  #    :taxon_name => ['Loxodonta afticana', 'Loxadonta afacana']
  # }
  # Expects a single grouped matching record.
  def error_selector(matching_records)
    res = {}
    column_names.each do |cn|
      res[cn] = matching_records.select(cn).uniq.map(&cn.to_sym)
    end
    res
  end
end
