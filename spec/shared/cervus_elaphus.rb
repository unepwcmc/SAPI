shared_context "Cervus elaphus" do
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Artiodactyla'),
      :parent => cites_eu_mammalia
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Cervidae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Cervus'),
      :parent => @family
    )
    @species = create_cites_eu_species(

      :taxon_name => create(:taxon_name, :scientific_name => 'Elaphus'),
      :parent => @genus
    )
    @subspecies1 = create_cites_eu_subspecies(
      :taxon_name => create(:taxon_name, :scientific_name => 'Bactrianus'),
      :parent => @species
    )
    @subspecies2 = create_cites_eu_subspecies(
      :taxon_name => create(:taxon_name, :scientific_name => 'Barbarus'),
      :parent => @species
    )
    @subspecies3 = create_cites_eu_subspecies(
      :taxon_name => create(:taxon_name, :scientific_name => 'Hanglu'),
      :parent => @species
    )
    @subspecies4 = create_cites_eu_subspecies(
      :taxon_name => create(:taxon_name, :scientific_name => 'Canadensis'),
      :parent => @species
    )

    create_cites_II_addition(
      :taxon_concept => @subspecies1,
      :effective_at => '1975-07-01',
      :is_current => true
    )
    create_cites_III_addition(
      :taxon_concept => @subspecies2,
      :effective_at => '1976-04-22',
      :is_current => true
    )
    create_cites_I_addition(
      :taxon_concept => @subspecies3,
      :effective_at => '1975-07-01',
      :is_current => true
    )

    create_eu_B_addition(
      :taxon_concept => @subspecies1,
      :effective_at => '2013-10-08',
      :event => reg2013,
      :is_current => true
    )
    create_eu_C_addition(
      :taxon_concept => @subspecies2,
      :effective_at => '2013-10-08',
      :event => reg2013,
      :is_current => true
    )
    create_eu_A_addition(
      :taxon_concept => @subspecies3,
      :effective_at => '2013-10-08',
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
