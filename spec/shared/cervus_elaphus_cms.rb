shared_context "Cervus elaphus CMS" do
  before(:all) do
    @order = create_cms_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Artiodactyla'),
      :parent => cms_mammalia
    )
    @family = create_cms_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Cervidae'),
      :parent => @order
    )
    @genus = create_cms_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Cervus'),
      :parent => @family
    )
    @species = create_cms_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Elaphus'),
      :parent => @genus
    )
    @subspecies1 = create_cms_subspecies(
      :taxon_name => create(:taxon_name, :scientific_name => 'Bactrianus'),
      :parent => @species
    )
    @subspecies2 = create_cms_subspecies(
      :taxon_name => create(:taxon_name, :scientific_name => 'Barbarus'),
      :parent => @species
    )

    create_cms_I_addition(
      :taxon_concept => @species,
      :effective_at => '1979-01-01',
      :is_current => true
    )
    create_cms_I_addition(
      :taxon_concept => @subspecies2,
      :effective_at => '1979-01-01',
      :is_current => true
    )
    create_cms_I_addition(
      :taxon_concept => @species,
      :effective_at => '2006-02-23',
      :is_current => true
    )
    create_cms_II_addition(
      :taxon_concept => @species,
      :effective_at => '2006-02-23',
      :is_current => true
    )

    create(
      :taxon_instrument,
      :taxon_concept => @subspecies1,
      :instrument => create(:instrument, :name => 'Bukhara Deer')
    )

    Sapi::StoredProcedures.rebuild_cms_taxonomy_and_listings
    self.instance_variables.each do |t|
      #Skip old sapi context let statements,
      #which are now instance variables starting with _
      next if t.to_s.include?('@_')
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t, MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
        self.instance_variable_set(:"#{t}_ac",
          MAutoCompleteTaxonConcept.
          where(:id => var.id).first
        )
      end
    end
  end
end
