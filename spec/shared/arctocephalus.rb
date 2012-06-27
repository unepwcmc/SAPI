shared_context "Arctocephalus" do
  before(:all) do
    @klass = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Mammalia').id)
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Carnivora'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Otariidae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Arctocephalus'),
      :parent => @family
    )
    @species1 = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Australis'),
      :parent => @genus
    )
    @species2 = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Townsendi'),
      :parent => @genus
    )

    create(
     :cites_II_addition,
     :taxon_concept => @genus,
     :effective_at => '1977-02-04'
    )
    create(
     :cites_II_addition,
     :taxon_concept => @species1,
     :effective_at => '1975-07-01'
    )
    create(
     :cites_II_addition,
     :taxon_concept => @species2,
     :effective_at => '1975-07-01'
    )
    create(
     :cites_I_addition,
     :taxon_concept => @species2,
     :effective_at => '1979-06-28'
    )

    Sapi::fix_listing_changes
    Sapi::rebuild
    [@klass, @order, @family, @genus, @species1, @species2].each do |t|
      t.reload
    end
  end
end