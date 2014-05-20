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
  let(:spain){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Spain',
      :iso_code2 => 'ES'
    )
  }
  let(:greece){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Greece',
      :iso_code2 => 'GR'
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
      :taxon_name => create(:taxon_name, :scientific_name => 'crassodon'),
      :parent => @species
    )

    [bhutan, india, nepal, pakistan, poland, spain, greece].each do |country|
      create(
        :distribution,
        :taxon_concept => @species,
        :geo_entity => country
      )
    end

    create_cites_II_addition(
     :taxon_concept => @species,
     :effective_at => '1977-02-04'
    )
    create_cites_II_addition(
     :taxon_concept => @subspecies,
     :effective_at => '1977-02-04',
     :inclusion_taxon_concept_id => @species.id,
     :is_current => true
    )
    cites_lc_I = create_cites_I_addition(
     :taxon_concept => @species,
     :effective_at => '2010-06-23',
     :is_current => true
    )
    cites_lc_II = create_cites_II_addition(
     :taxon_concept => @species,
     :effective_at => '2010-06-23',
     :is_current => true
    )
    cites_lc_II_exc = create_cites_II_exception(
      :taxon_concept => @species,
      :effective_at => '2010-06-23',
      :parent_id => cites_lc_II.id
    )
    [bhutan, india, nepal, pakistan].each do |country|
      create(
        :listing_distribution,
        :geo_entity => country,
        :listing_change => cites_lc_I,
        :is_party => false
      )
      create(
        :listing_distribution,
        :geo_entity => country,
        :listing_change => cites_lc_II_exc,
        :is_party => false
      )
    end

    eu_lc_A = create_eu_A_addition(
      :taxon_concept => @species,
      :effective_at => '2013-10-08',
      :event => reg2013,
      :is_current => true
    )
    eu_lc_A_exc = create_eu_A_exception(
      :taxon_concept => @species,
      :effective_at => '2013-10-08',
      :event => reg2013,
      :parent_id => eu_lc_A.id
    )
    eu_lc_B = create_eu_B_addition(
      :taxon_concept => @species,
      :effective_at => '2013-10-08',
      :event => reg2013,
      :is_current => true
    )

    [spain, greece].each do |country|
      create(
        :listing_distribution,
        :geo_entity => country,
        :listing_change => eu_lc_B,
        :is_party => false
      )
      create(
        :listing_distribution,
        :geo_entity => country,
        :listing_change => eu_lc_A_exc,
        :is_party => false
      )
    end

    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    self.instance_variables.each do |t|
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t,MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
        self.instance_variable_set(:"#{t}_ac",
          MAutoCompleteTaxonConcept.
          where(:id => var.id).first
        )
      end
    end
  end
end
