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

class Trade::TaxonConceptAppendixYearValidationRule < Trade::InclusionValidationRule

  def validation_errors_for_shipment(shipment)
    return nil unless shipment_in_scope?(shipment)
    # if it is, check if it has a match in valid values view
    v = Arel::Table.new(valid_values_view)
    appendix_node = v['appendix'].eq(shipment.appendix)
    effective_from = Arel::Nodes::NamedFunction.new "DATE_PART", ["year", v['effective_from']]
    effective_to = Arel::Nodes::NamedFunction.new "DATE_PART", ["year", v['effective_to']]
    year_node = effective_from.lteq(shipment.year).and(effective_to.gteq(shipment.year).or(effective_to.eq(nil)))
    taxon_concept_node = v['taxon_concept_id'].eq(shipment.taxon_concept_id)
    conditions = appendix_node.and(year_node).and(taxon_concept_node)
    return nil if Trade::Shipment.find_by_sql(v.project('*').where(conditions)).any?
    error_message
  end

  private

  def year_join_node(s, v)
    sandbox_year = Arel::Nodes::NamedFunction.new "CAST", [s['year'].as('INT')]
    effective_from = Arel::Nodes::NamedFunction.new "DATE_PART", ["year", v['effective_from']]
    effective_to = Arel::Nodes::NamedFunction.new "DATE_PART", ["year", v['effective_to']]
    effective_from.lteq(sandbox_year).and(effective_to.gteq(sandbox_year).or(effective_to.eq(nil)))
  end

  def taxon_concept_join_node(s, v)
    s['taxon_concept_id'].eq(v['taxon_concept_id'])
  end

  def appendix_join_node(s, v)
    s['appendix'].eq(v['appendix'])
  end

  # Difference from superclass: rather than equality, check if appendix
  # is contained in valid appendix array (to allow for split listings)
  def matching_records_arel(table_name)
    s = Arel::Table.new("#{table_name}_view")
    v = Arel::Table.new(valid_values_view)

    join_conditions = appendix_join_node(s, v).and(year_join_node(s, v)).
      and(taxon_concept_join_node(s, v))
    valid_values = s.project(s['*']).join(v).on(join_conditions)
    not_null_nodes = column_names.map do |c|
      s[c].not_eq(nil)
    end
    not_null_conds = not_null_nodes.shift
    not_null_nodes.each { |n| not_null_conds = not_null_conds.and(n) }
    s.project('*').where(not_null_conds).except(valid_values)
  end

end
