shared_context "Cervus elaphus" do
  before(:all) do
    @klass = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Mammalia').id)
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Artiodactyla'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Cervidae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Cervus'),
      :parent => @family
    )
    @species = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Elaphus'),
      :parent => @genus
    )
    @subspecies1 = create(
      :subspecies,
      :taxon_name => create(:taxon_name, :scientific_name => 'Bactrianus'),
      :parent => @species
    )
    @subspecies2 = create(
      :subspecies,
      :taxon_name => create(:taxon_name, :scientific_name => 'Barbarus'),
      :parent => @species
    )
    @subspecies3 = create(
      :subspecies,
      :taxon_name => create(:taxon_name, :scientific_name => 'Hanglu'),
      :parent => @species
    )
    @subspecies4 = create(
      :subspecies,
      :taxon_name => create(:taxon_name, :scientific_name => 'Canadensis'),
      :parent => @species
    )

    create(
     :cites_II_addition,
     :taxon_concept => @subspecies1,
     :effective_at => '1975-07-01',
     :is_current => true
    )
    create(
     :cites_III_addition,
     :taxon_concept => @subspecies2,
     :effective_at => '1976-04-22',
     :is_current => true
    )
    create(
     :cites_I_addition,
     :taxon_concept => @subspecies3,
     :effective_at => '1975-07-01',
     :is_current => true
    )

    Sapi::rebuild(:except => [:names_and_ranks, :taxonomic_positions])
    self.instance_variables.each do |t|
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t,MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end