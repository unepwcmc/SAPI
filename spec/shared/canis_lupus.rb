shared_context "Canis lupus" do
  before(:all) do
    @klass = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Mammalia').id)
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Carnivora'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Canidae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Canis'),
      :parent => @family
    )
    @species = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Lupus'),
      :parent => @genus,
      :fully_covered => false
    )

    create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '1977-02-04'
    )
    create(
     :cites_I_addition,
     :taxon_concept => @species,
     :effective_at => '1979-06-28'
    )
    create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '1979-06-28'
    )
    create(
     :cites_I_addition,
     :taxon_concept => @species,
     :effective_at => '2010-06-23'
    )
    create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '2010-06-23'
    )

    Sapi::fix_listing_changes
    Sapi::rebuild
    self.instance_variables.each do |t|
      self.instance_variable_get(t).reload
    end
  end
end
