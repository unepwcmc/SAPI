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

class Trade::PovInclusionValidationRule < Trade::InclusionValidationRule

  private

  # Returns a hash with column values to be used to select invalid rows.
  # e.g.
  # {
  #    :species_name => 'Loxodonta africana',
  #    :term_code => 'CAV'
  #
  # }
  # Expects a single grouped matching record.
  # Renames 'exporter' / 'importer' to 'trading_partner'
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

  # Difference from superclass: test on sandbox view rather than table
  # to allow for POV checks
  def matching_records_arel(table_name)
    s = Arel::Table.new("#{table_name}_view")
    v = Arel::Table.new(valid_values_view)
    arel_nodes = column_names.map do |c|
      v[c].eq(s[c])
    end
    join_conditions = arel_nodes.shift
    arel_nodes.each{ |n| join_conditions = join_conditions.and(n) }
    valid_values = s.project(s['*']).join(v).on(join_conditions)
    scoped_records_arel(s).except(valid_values)
  end

end
