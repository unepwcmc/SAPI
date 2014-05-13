#Encoding: utf-8
shared_context 'Colophon' do
  let(:country){
    create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
  }
  let(:south_africa){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'South Africa',
      :iso_code2 => 'ZA'
    )
  }

  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Coleoptera'),
      :parent => cites_eu_insecta
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Lucanidae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Colophon'),
      :parent => @family,
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'barnardi'),
      :parent => @genus,
    )

    cites_lc = create_cites_III_addition(
     :taxon_concept => @genus,
     :effective_at => '2000-09-13',
     :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => south_africa,
      :listing_change => cites_lc,
      :is_party => true
    )

    eu_lc = create_eu_C_addition(
     :taxon_concept => @genus,
     :effective_at => '2013-10-08',
     :event => reg2013,
     :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => south_africa,
      :listing_change => eu_lc,
      :is_party => true
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
