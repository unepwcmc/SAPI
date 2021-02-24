shared_context "Moschus" do
  {
    bhutan: 'BT',
    india: 'IN',
    nepal: 'NP',
    china: 'CH',
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
      :taxon_name => create(:taxon_name, :scientific_name => 'Artiodactyla'),
      :parent => cites_eu_mammalia
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Moschidae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Moschus'),
      :parent => @family
    )
    @species1 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'leucogaster'),
      :parent => @genus
    )
    @species2 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'moschiferus'),
      :parent => @genus
    )
    @subspecies = create_cites_eu_subspecies(
      :taxon_name => create(:taxon_name, :scientific_name => 'moschiferus'),
      :parent => @species2
    )

    [bhutan, india, nepal].each do |country|
      create(
        :distribution,
        :taxon_concept => @species1,
        :geo_entity => country
      )
    end
    [@species2, @subspecies].each do |taxon|
      create(
        :distribution,
        :taxon_concept => taxon,
        :geo_entity => china
      )
    end

    create_cites_I_addition(
      :taxon_concept => @subspecies,
      :effective_at => '1975-07-01',
      :is_current => false
    )

    create_cites_II_addition(
      :taxon_concept => @genus,
      :effective_at => '1979-06-28',
      :is_current => false
    )

    lc = create_cites_I_addition(
      :taxon_concept => @species2,
      :effective_at => '1979-06-28',
      :is_current => false
    )
    create(
      :listing_distribution,
      :geo_entity => china,
      :listing_change => lc,
      :is_party => false
    )

    create_cites_II_addition(
      :taxon_concept => @species2,
      :effective_at => '1979-06-28',
      :inclusion_taxon_concept_id => @genus.id,
      :is_current => false
    )

    create_cites_I_addition(
      :taxon_concept => @subspecies,
      :effective_at => '1979-06-28',
      :inclusion_taxon_concept_id => @species2.id,
      :is_current => true
    )

    cites_lc1 = create_cites_I_addition(
      :taxon_concept => @genus,
      :effective_at => '1983-07-29',
      :is_current => true
    )
    [bhutan, india, nepal].each do |country|
      create(
        :listing_distribution,
        :geo_entity => country,
        :listing_change => cites_lc1,
        :is_party => false
      )
    end
    cites_lc2 = create_cites_II_addition(
      :taxon_concept => @genus,
      :effective_at => '1983-07-29',
      :is_current => true
    )

    cites_lc2_exc = create_cites_II_exception(
      :taxon_concept => @genus,
      :effective_at => '1983-07-29',
      :parent_id => cites_lc2.id
    )
    [bhutan, india, nepal].each do |country|
      create(
        :listing_distribution,
        :geo_entity => country,
        :listing_change => cites_lc2_exc,
        :is_party => false
      )
    end

    cites_lc3 = create_cites_I_deletion(
      :taxon_concept => @species2,
      :effective_at => '1983-07-29',
      :is_current => false
    )

    create(
      :listing_distribution,
      :geo_entity => china,
      :listing_change => cites_lc3,
      :is_party => false
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
