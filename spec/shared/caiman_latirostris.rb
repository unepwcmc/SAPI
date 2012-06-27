shared_context "Caiman latirostris" do
  before(:all) do
    @klass = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Reptilia').id)
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Crocodylia'),
      :parent => @klass
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Alligatoridae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Caiman'),
      :parent => @family
    )
    @species = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Latirostris'),
      :parent => @genus
    )

    create(
     :cites_I_addition,
     :taxon_concept => @species,
     :effective_at => '1975-07-01'
    )
    create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '1997-09-18'
    )

    Sapi::fix_listing_changes
    Sapi::rebuild
    [@klass, @order, @family, @genus, @species].each do |t|
      t.reload
    end
  end
end