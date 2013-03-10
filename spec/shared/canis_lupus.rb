shared_context "Canis lupus" do
  let(:country){
    create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
  }
  let(:bhutan){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Bhutan',
      :iso_code2 => 'BT'
    )
  }
  let(:india){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'India',
      :iso_code2 => 'IN'
    )
  }
  let(:nepal){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Nepal',
      :iso_code2 => 'NP'
    )
  }
  let(:pakistan){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Pakistan',
      :iso_code2 => 'PK'
    )
  }
  let(:poland){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Poland',
      :iso_code2 => 'PL'
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
      :taxon_name => create(:taxon_name, :scientific_name => 'Carnivora'),
      :parent => cites_eu_mammalia
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Canidae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Canis'),
      :parent => @family
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Lupus'),
      :parent => @genus
    )
    @subspecies = create_cites_eu_subspecies(
      :taxon_name => create(:taxon_name, :scientific_name => 'familiaris'),
      :parent => @species
    )


    create_cites_II_addition(
     :taxon_concept => @species,
     :effective_at => '1977-02-04'
    )
    l1 = create_cites_I_addition(
     :taxon_concept => @species,
     :effective_at => '1979-06-28'
    )
    [bhutan, india, nepal, pakistan].each do |country|
      create(
        :listing_distribution,
        :geo_entity => country,
        :listing_change => l1,
        :is_party => false
      )
    end
    create_cites_II_addition(
     :taxon_concept => @species,
     :effective_at => '1979-06-28'
    )

    l2 = create_cites_I_addition(
     :taxon_concept => @species,
     :effective_at => '2010-06-23',
     :is_current => true
    )
    create_cites_I_exception(
      :taxon_concept => @subspecies,
      :effective_at => '2010-06-23',
      :parent_id => l2.id,
     :is_current => true
    )
    l3 = create_cites_II_addition(
     :taxon_concept => @species,
     :effective_at => '2010-06-23',
     :is_current => true
    )
    l3_exc = create_cites_II_exception(
      :taxon_concept => @species,
      :effective_at => '1979-06-28',
      :parent_id => l3.id,
     :is_current => true
    )
    [bhutan, india, nepal, pakistan].each do |country|
      create(
        :listing_distribution,
        :geo_entity => country,
        :listing_change => l2,
        :is_party => false
      )
      create(
        :listing_distribution,
        :geo_entity => country,
        :listing_change => l3_exc,
        :is_party => false
      )
    end

    [bhutan, india, nepal, pakistan, poland].each do |country|
      create(
        :distribution,
        :taxon_concept => @species,
        :geo_entity => country
      )
    end

    Sapi::rebuild(:except => [:names_and_ranks, :taxonomic_positions])
    self.instance_variables.each do |t|
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t,MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end
