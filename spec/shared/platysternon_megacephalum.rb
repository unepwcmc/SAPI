shared_context 'Platysternon megacephalum' do
  before(:all) do
    @klass = cites_eu_reptilia
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Testudines'),
      :parent => @klass
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Platysternidae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Platysternon'),
      :parent => @family
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'megacephalum'),
      :parent => @genus
    )

    create_cites_II_addition(
      :taxon_concept => @species,
      :effective_at => '2003-02-13',
      :is_current => false
    )

    create_eu_B_addition(
      :taxon_concept => @species,
      :effective_at => '2012-12-15',
      :event => reg2012,
      :is_current => false
    )

    create_cites_I_addition(
      :taxon_concept => @family,
      :effective_at => '2013-06-12',
      :is_current => true
    )

    create_eu_A_addition(
      :taxon_concept => @family,
      :effective_at => '2013-08-10',
      :event => reg2013,
      :is_current => true
    )

    create_cites_I_addition(
      :taxon_concept => @species,
      :effective_at => '2013-06-12',
      :inclusion_taxon_concept_id => @family.id,
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
