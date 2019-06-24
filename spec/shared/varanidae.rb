shared_context 'Varanidae' do
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Sauria'),
      :parent => cites_eu_reptilia
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Varanidae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Varanus'),
      :parent => @family
    )
    @species1 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Bengalensis'),
      :parent => @genus
    )
    @species2 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Bushi'),
      :parent => @genus
    )

    create_cites_II_addition(
      :taxon_concept => @genus,
      :effective_at => '1975-07-01',
      :is_current => true
    )
    create_cites_I_addition(
      :taxon_concept => @species1,
      :effective_at => '1975-07-01',
      :is_current => true
    )

    create_eu_B_addition(
      :taxon_concept => @genus,
      :effective_at => '2013-10-08',
      :event => reg2013,
      :is_current => true
    )
    create_eu_A_addition(
      :taxon_concept => @species1,
      :effective_at => '2013-10-08',
      :event => reg2013,
      :is_current => true
    )

    @ref1 = create(
      :reference,
      :author => 'Böhme, W.',
      :title =>
        'Checklist of the living monitor lizards of the world (family Varanidae)',
      :year => 2003
    )
    @ref2 = create(
      :reference,
      :author => 'Aplin, K. P., Fitch, A. J. & King, D. J.',
      :title =>
        'A new species of Varanus Merrem (Squamata: Varanidae) from the Pilbara
        region of Western Australia, with observations on sexual dimorphism in
        closely related species.',
      :year => 2006
    )

    create(
      :taxon_concept_reference,
      :taxon_concept => @family,
      :reference => @ref1,
      :is_standard => true,
      :is_cascaded => true
    )
    create(
      :taxon_concept_reference,
      :taxon_concept => @species2,
      :reference => @ref2,
      :is_standard => true,
      :is_cascaded => true
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
