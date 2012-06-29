shared_context "Mellivora capensis" do
  before(:all) do
    @klass = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Mammalia').id)
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Carnivora'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Mustelidae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Mellivora'),
      :parent => @family
    )
    @species = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Capensis'),
      :parent => @genus
    )

    ghana = create(
      :country,
      :name => 'Ghana',
      :iso_code2 => 'GH'
    )
    botswana = create(
      :country,
      :name => 'Botswana',
      :iso_code2 => 'BW'
    )
    create(
     :cites_III_addition,
     :taxon_concept => @species,
     :effective_at => '1976-02-26',
     :party => ghana
    )
    create(
     :cites_III_addition,
     :taxon_concept => @species,
     :effective_at => '1978-04-24',
     :party => botswana
    )
    create(
     :cites_III_deletion,
     :taxon_concept => @species,
     :effective_at => '2007-03-04',
     :party => ghana
    )

    Sapi::fix_listing_changes
    Sapi::rebuild
    self.instance_variables.each do |t|
      self.instance_variable_get(t).reload
    end
  end
end
