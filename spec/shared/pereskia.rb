shared_context "Pereskia" do
  before(:all) do
    @kingdom = TaxonConcept.find_by_taxon_name_id(TaxonName.find_by_scientific_name('Plantae').id)
    @order = create(
      :order,
      :taxon_name => create(:taxon_name, :scientific_name => 'Caryophyllales'),
      :parent => @kingdom
    )
    @family = create(
      :family,
      :taxon_name => create(:taxon_name, :scientific_name => 'Cactacea'),
      :parent => @order
    )
    @genus1 = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Pereskia'),
      :parent => @family,
      :not_in_cites => true
    )
    @genus2 = create(
      :genus,
      :taxon_name => create(:taxon_name, :scientific_name => 'Ariocarpus'),
      :parent => @family
    )

    create(
     :cites_II_addition,
     :taxon_concept => @family,
     :effective_at => '2010-06-23'
    )
    create(
     :cites_II_addition,
     :taxon_concept => @genus2,
     :effective_at => '1975-07-01'
    )
    create(
     :cites_I_addition,
     :taxon_concept => @genus2,
     :effective_at => '1992-06-11'
    )

    Sapi::rebuild
    [@kingdom, @order, @family, @genus1, @genus2].each do |t|
      t.reload
    end
  end
end
