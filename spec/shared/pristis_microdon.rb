shared_context 'Pristis microdon' do
  before(:all) do
    @klass = cites_eu_elasmobranchii
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Pristiformes'),
      :parent => @klass
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Pristidae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Pristis'),
      :parent => @family
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'microdon'),
      :parent => @genus
    )

    create_cites_I_addition(
      :taxon_concept => @family,
      :effective_at => '2007-09-13',
      :is_current => true
    )
    create_cites_II_addition(
      :taxon_concept => @species,
      :effective_at => '2007-09-13',
      :is_current => false
    )
    create_cites_I_addition(
      :taxon_concept => @species,
      :effective_at => '2013-06-12',
      :inclusion_taxon_concept_id => @family.id,
      :is_current => true
    )

    eu_lc = create_eu_A_addition(
      :taxon_concept => @family,
      :effective_at => '2012-12-15',
      :event => reg2012,
      :is_current => false
    )
    create_eu_A_exception(
      :taxon_concept => @species,
      :effective_at => '2012-12-15',
      :parent_id => eu_lc.id
    )
    create_eu_B_addition(
      :taxon_concept => @family,
      :effective_at => '2012-12-15',
      :event => reg2012,
      :is_current => false
    )
    create_eu_A_addition(
      :taxon_concept => @family,
      :effective_at => '2013-08-10',
      :event => reg2013,
      :is_current => true
    )

    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    self.instance_variables.each do |t|
      #Skip old sapi context let statements,
      #which are now instance variables starting with _
      next if t.to_s.include?('@_')
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t, MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end
