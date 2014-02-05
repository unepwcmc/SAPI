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

class Trade::TaxonConceptAppendixYearValidationRule < Trade::InclusionValidationRule

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
    
    # if appendix given as N, check in the valid annex view
    if shipment.appendix == 'N'
      v = Arel::Table.new('valid_species_name_annex_year_mview')
    else
      v = Arel::Table.new(valid_values_view)
      appendix_node = v['appendix'].eq(shipment.appendix)
    end
    
    effective_from = Arel::Nodes::NamedFunction.new "DATE_PART", ["year", v['effective_from']]
    effective_to = Arel::Nodes::NamedFunction.new "DATE_PART", ["year", v['effective_to']]
    year_node = effective_from.lteq(shipment.year).and(effective_to.gteq(shipment.year).or(effective_to.eq(nil)))
    taxon_concept_node = v['taxon_concept_id'].eq(shipment.taxon_concept_id)
    conditions = if appendix_node
      appendix_node.and(year_node).and(taxon_concept_node)
    else
      year_node.and(taxon_concept_node)
    end
    return nil if Trade::Shipment.find_by_sql(v.project('*').where(conditions)).any?
    error_message
  end

  private

  def year_join_node(s, v)
    sandbox_year = Arel::Nodes::NamedFunction.new "CAST", [ s['year'].as('INT') ]
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

  def appendix_n_join_node(s, v)
    s['appendix'].eq('N')
  end

  # rows that have a match on species name + appendix + year in valid appendix mview
  def valid_values_arel(s)
    v = Arel::Table.new(valid_values_view)
    join_conditions = appendix_join_node(s, v).and(year_join_node(s, v)).
      and(taxon_concept_join_node(s, v))
    s.project(s['*']).join(v).on(join_conditions)
  end

  # rows reported at appendix N
  # which have a match on species name + year in valid annex mview
  # and do not have a match on species name + year in valid appendix mview
  def valid_appendix_n_values_arel(s)
    v = Arel::Table.new('valid_species_name_annex_year_mview')
    join_conditions = appendix_n_join_node(s, v).and(year_join_node(s, v)).
      and(taxon_concept_join_node(s, v))
    s.project(s['*']).join(v).on(join_conditions).except(
      invalid_appendix_n_values_arel(s)
    )
  end

  def invalid_appendix_n_values_arel(s)
    v = Arel::Table.new(valid_values_view)
    join_conditions = appendix_n_join_node(s, v).and(year_join_node(s, v)).
      and(taxon_concept_join_node(s, v))
    s.project(s['*']).join(v).on(join_conditions)
  end

  # Difference from superclass: rather than equality, check if appendix
  # is contained in valid appendix array (to allow for split listings)
  def matching_records_arel(table_name)
    s = Arel::Table.new(table_name)

    not_null_nodes = column_names.map do |c|
      s[c].not_eq(nil)
    end
    not_null_conds = not_null_nodes.shift
    not_null_nodes.each{ |n| not_null_conds = not_null_conds.and(n) }
    
    # for some reason Arel doesn't like chaining set operations (union, except)
    # so to make this work I'm wraping them in subqueries
    s.project('*').where(not_null_conds).except(
      s.project('*').from(
        valid_values_arel(s).union(
          s.project('*').from(
            valid_appendix_n_values_arel(s).to_sql + 'AS valid_nc_values'
          )
        ).to_sql + 'AS valid_values'
      )
    )
  end

end
