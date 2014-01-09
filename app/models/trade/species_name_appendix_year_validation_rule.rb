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

class Trade::SpeciesNameAppendixYearValidationRule < Trade::InclusionValidationRule

  def validation_errors_for_shipment(shipment)
    shipment_in_scope = true
    # check if shipment is in scope of this validation
    shipments_scope.each do |scope_column, scope_value|
      shipment_in_scope = false if shipment.send(scope_column) != scope_value
    end
    # make sure the validated fields are not blank
    shipments_columns.each do |column|
      shipment_in_scope = false if shipment.send(column).blank?
    end
    return nil unless shipment_in_scope
    # if it is, check if it has a match in valid values view
    v = Arel::Table.new(valid_values_view)
    actual_appendix = Arel::Nodes::NamedFunction.new('ANY', [v['appendix']])
    appendix_node = Arel::Nodes::Equality.new(shipment.appendix, actual_appendix)
    actual_year = v['year']
    year_node = actual_year.eq(shipment.year)
    actual_species_name = v['species_name']
    species_name_node = actual_species_name.eq(shipment.taxon_concept.full_name)
    conditions = appendix_node.and(year_node).and(species_name_node)
    return nil if Trade::Shipment.find_by_sql(v.project('*').where(conditions)).any?
    error_message
  end

  private

  # Difference from superclass: rather than equality, check if appendix
  # is contained in valid appendix array (to allow for split listings)
  def matching_records_arel(table_name)
    s = Arel::Table.new(table_name)
    v = Arel::Table.new(valid_values_view)

    sandbox_appendix = s['appendix']
    actual_appendix = Arel::Nodes::NamedFunction.new('ANY', [v['appendix']])
    appendix_node = sandbox_appendix.eq(actual_appendix)
    sandbox_year = Arel::Nodes::NamedFunction.new "CAST", [ s['year'].as('INT') ]
    actual_year = v['year']
    year_node = sandbox_year.eq(actual_year)
    sandbox_species_name = s['species_name']
    actual_species_name = v['species_name']
    species_name_node = sandbox_species_name.eq(actual_species_name)

    join_conditions = appendix_node.and(year_node).and(species_name_node)
    valid_values = s.project(s['*']).join(v).on(join_conditions)
    not_null_nodes = column_names.map do |c|
      s[c].not_eq(nil)
    end
    not_null_conds = not_null_nodes.shift
    not_null_nodes.each{ |n| not_null_conds = not_null_conds.and(n) }
    s.project('*').where(not_null_conds).except(valid_values)
  end

end
