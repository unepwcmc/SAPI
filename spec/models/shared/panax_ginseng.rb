shared_context "Panax ginseng" do
  before(:all) do
    @kingdom = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Plantae').id)
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Apiales'),
      :parent => @kingdom
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Araliaceae'),
      :parent => @order
    )
    @genus = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Panax'),
      :parent => @family
    )
    @species = create(
      :species,
      :taxon_name => create(:taxon_name, :scientific_name => 'Ginseng'),
      :parent => @genus,
      :fully_covered => false
    )

    create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '2000-07-19'
    )

    Sapi::rebuild
    [@kingdom, @order, @family, @genus, @species].each do |t|
      t.reload
    end
  end
end
