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

    create(
     :cites_II_addition,
     :taxon_concept => @subspecies1,
     :effective_at => '1975-07-01'
    )
    create(
     :cites_III_addition,
     :taxon_concept => @subspecies2,
     :effective_at => '1976-04-22'
    )
    create(
     :cites_I_addition,
     :taxon_concept => @subspecies3,
     :effective_at => '1975-07-01'
    )
    create(
     :cites_I_addition,
     :taxon_concept => @species2,
     :effective_at => '1979-06-28'
    )

    Sapi::fix_listing_changes
    Sapi::rebuild
    self.instance_variables.each do |t|
      self.instance_variable_get(t).reload
    end
  end
end