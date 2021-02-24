shared_context "Loxodonta africana" do
  {
    ghana: 'GH',
    botswana: 'BW',
    namibia: 'NA',
    zambia: 'ZA',
    zimbabwe: 'ZW'
  }.each do |name, iso_code|
    define_method(name) do
      name = name.to_s
      var = instance_variable_get("@#{name}")
      return var if var
      country =  create(
        :geo_entity,
        :geo_entity_type => country_geo_entity_type,
        :name => name.capitalize,
        :iso_code2 => iso_code
      )
      instance_variable_set("@#{name}", country)
    end
  end
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Proboscidea'),
      :parent => cites_eu_mammalia
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Elephantidae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Loxodonta'),
      :parent => @family
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Africana'),
      :parent => @genus
    )

    create(:distribution, :taxon_concept_id => @species.id, :geo_entity_id => botswana.id)

    cites_lc1 = create_cites_I_addition(
      :taxon_concept => @species,
      :effective_at => '1997-09-18'
    )
    cites_lc2 = create_cites_II_addition(
      :taxon_concept => @species,
      :effective_at => '1997-09-18'
    )
    [botswana, namibia, zimbabwe].each do |country|
      create(
        :listing_distribution,
        :geo_entity => country,
        :listing_change => cites_lc2,
        :is_party => false
      )
    end
    cites_lc1 = create_cites_I_addition(
      :taxon_concept => @species,
      :effective_at => '2000-07-19',
      :is_current => true
    )
    cites_lc2 = create_cites_II_addition(
      :taxon_concept => @species,
      :effective_at => '2000-07-19',
      :is_current => true
    )
    eu_lc1 = create_eu_A_addition(
      :taxon_concept => @species,
      :effective_at => '2013-08-10',
      :event => reg2013,
      :is_current => true
    )
    eu_lc2 = create_eu_B_addition(
      :taxon_concept => @species,
      :effective_at => '2013-08-10',
      :event => reg2013,
      :is_current => true
    )
    [botswana, namibia, zambia, zimbabwe].each do |country|
      create(
        :listing_distribution,
        :geo_entity => country,
        :listing_change => cites_lc2,
        :is_party => false
      )
      create(
        :listing_distribution,
        :geo_entity => country,
        :listing_change => eu_lc2,
        :is_party => false
      )
    end

    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    self.instance_variables.each do |t|
      #Skip old sapi context let statements,
      #which are now instance variables starting with _
      next if t.to_s.include?('@_')
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t, MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end
