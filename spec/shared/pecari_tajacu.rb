shared_context "Pecari tajacu" do
  let(:country){
    create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
  }
  let(:cites_region){
    create(:geo_entity_type, :name => GeoEntityType::CITES_REGION)
  }
  let(:contains){
    create(:geo_relationship_type, :name => GeoRelationshipType::CONTAINS)
  }
  let(:north_america){
    create(
      :geo_entity,
      :geo_entity_type => cites_region,
      :name => "5- North America"
    )
  }
  let(:south_america){
    create(
      :geo_entity,
      :geo_entity_type => cites_region,
      :name => "3- Central and South America and the Caribbean"
    )
  }
  let(:america){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'United States of America',
      :iso_code2 => 'US'
    )
  }
  let(:mexico){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Mexico',
      :iso_code2 => 'MX'
    )
  }
  let(:canada){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Canada',
      :iso_code2 => 'CA'
    )
  }
  let(:argentina){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Argentina',
      :iso_code2 => 'AR'
    )
  }
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Artiodactyla'),
      :parent => cites_eu_mammalia
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Tayassuidae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Pecari'),
      :parent => @family
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Tajacu'),
      :parent => @genus
    )

    cites_lc1 = create_cites_II_addition(
     :taxon_concept => @species,
     :effective_at => '1987-10-22',
     :is_current => true
    )
    cites_lc1_exc = create_cites_II_exception(
      :taxon_concept => @species,
      :effective_at => '1979-06-28',
      :parent_id => cites_lc1.id,
      :is_current => true
    )
    [america, mexico].each do |country|
      create(
        :listing_distribution,
        :geo_entity => country,
        :listing_change => cites_lc1_exc,
        :is_party => false
      )
    end

    [america, mexico, argentina].each do |country|
      create(
        :distribution,
        :taxon_concept => @species,
        :geo_entity => country
      )
    end

    [america, mexico, canada].each do |country|
      create(
        :geo_relationship,
        :geo_entity => north_america,
        :related_geo_entity => country,
        :geo_relationship_type => contains
      )
    end
    create(
      :geo_relationship,
      :geo_entity => south_america,
      :related_geo_entity => argentina,
      :geo_relationship_type => contains
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

