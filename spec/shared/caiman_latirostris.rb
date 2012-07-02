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

    argentina = create(
      :country,
      :name => 'Argentina',
      :iso_code2 => 'AR'
    )
    create(
     :cites_I_addition,
     :taxon_concept => @species,
     :effective_at => '1975-07-01'
    )
    l1 = create(
     :cites_II_addition,
     :taxon_concept => @species,
     :effective_at => '1997-09-18'
    )
    create(
      :listing_distribution,
      :geo_entity => argentina,
      :listing_change => l1,
      :is_party => false
    )

    Sapi::fix_listing_changes
    Sapi::rebuild
    self.instance_variables.each do |t|
      self.instance_variable_get(t).reload
    end
  end
end