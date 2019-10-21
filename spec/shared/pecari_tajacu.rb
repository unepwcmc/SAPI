shared_context "Pecari tajacu" do
  {
    argentina: 'AR',
    canada: 'CA',
    mexico: 'MX'
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

  def north_america
    @north_america ||=
      create(
        :geo_entity,
        :geo_entity_type => cites_region_geo_entity_type,
        :name => "5- North America"
      )
  end

  def south_america
    @south_america ||=
      create(
        :geo_entity,
        :geo_entity_type => cites_region_geo_entity_type,
        :name => "3- Central and South America and the Caribbean"
      )
  end

  def america
    @america ||=
      create(
        :geo_entity,
        :geo_entity_type => country_geo_entity_type,
        :name => 'United States of America',
        :iso_code2 => 'US'
      )
  end
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
        :geo_relationship_type => contains_geo_relationship_type
      )
    end
    create(
      :geo_relationship,
      :geo_entity => south_america,
      :related_geo_entity => argentina,
      :geo_relationship_type => contains_geo_relationship_type
    )

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
