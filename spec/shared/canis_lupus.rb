shared_context "Canis lupus" do
  {
    bhutan: 'BT',
    india: 'IN',
    nepal: 'NP',
    pakistan: 'PK',
    poland: 'PL',
    argentina: 'AR',
    spain: 'ES',
    greece: 'GR'
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
      #Skip old sapi context let statements,
      #which are now instance variables starting with _
      next if t.to_s.include?('@_')
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t, MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
        self.instance_variable_set(:"#{t}_ac",
          MAutoCompleteTaxonConcept.
          where(:id => var.id).first
        )
      end
    end
  end
end
