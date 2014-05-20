shared_context "Mellivora capensis" do
  let(:country){
    create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
  }
  let(:ghana){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Ghana',
      :iso_code2 => 'GH'
    )
  }
  let(:botswana){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Botswana',
      :iso_code2 => 'BW'
    )
  }
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Carnivora'),
      :parent => cites_eu_mammalia
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Mustelinae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Mellivora'),
      :parent => @family
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Capensis'),
      :parent => @genus
    )

    cites_lc1 = create_cites_III_addition(
     :taxon_concept => @species,
     :effective_at => '1976-02-26',
     :is_current => false
    )
    create(
      :listing_distribution,
      :geo_entity => ghana,
      :listing_change => cites_lc1
    )
    cites_lc2 = create_cites_III_addition(
     :taxon_concept => @species,
     :effective_at => '1978-04-24',
     :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => botswana,
      :listing_change => cites_lc2
    )
    cites_lc3 = create_cites_III_deletion(
     :taxon_concept => @species,
     :effective_at => '2007-03-04',
     :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => ghana,
      :listing_change => cites_lc3
    )

    eu_lc1 = create_eu_C_addition(
     :taxon_concept => @species,
     :effective_at => '2005-08-22',
     :event => reg2005
    )
    create(
      :listing_distribution,
      :geo_entity => botswana,
      :listing_change => eu_lc1
    )
    eu_lc2 = create_eu_C_addition(
     :taxon_concept => @species,
     :effective_at => '2005-08-22',
     :event => reg2005
    )
    create(
      :listing_distribution,
      :geo_entity => ghana,
      :listing_change => eu_lc2
    )
    eu_lc3 = create_eu_C_addition(
     :taxon_concept => @species,
     :effective_at => '2008-04-11',
     :event => reg2008
    )
    create(
      :listing_distribution,
      :geo_entity => botswana,
      :listing_change => eu_lc3
    )
    eu_lc4 = create_eu_C_deletion(
     :taxon_concept => @species,
     :effective_at => '2008-04-11',
     :event => reg2008
    )
    create(
      :listing_distribution,
      :geo_entity => ghana,
      :listing_change => eu_lc4
    )
    eu_lc5 = create_eu_C_addition(
     :taxon_concept => @species,
     :effective_at => '2013-08-10',
     :event => reg2013,
     :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => botswana,
      :listing_change => eu_lc3
    )

    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    self.instance_variables.each do |t|
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t,MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end
