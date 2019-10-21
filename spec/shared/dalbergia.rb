shared_context "Dalbergia" do
  def en
    @en ||= create(:language, :name => 'English', :iso_code1 => 'EN', :iso_code3 => 'ENG')
  end
  def es
    @es ||= create(:language, :name => 'Spanish', :iso_code1 => 'ES', :iso_code3 => 'SPA')
  end
  def fr
    @fr ||= create(:language, :name => 'French', :iso_code1 => 'FR', :iso_code3 => 'FRA')
  end
  {
    madagascar: 'MG',
    thailand: 'TH'
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
      :taxon_name => create(:taxon_name, :scientific_name => 'Fabales'),
      :parent => cites_eu_plantae.reload # reload is needed for full name
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Leguminosae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Dalbergia'),
      :parent => @family
    )
    @species1 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'abbreviata'),
      :parent => @genus
    )
    @species2 = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'abrahamii'),
      :parent => @genus
    )

    create(
      :distribution,
      :taxon_concept_id => @species1.id,
      :geo_entity_id => thailand.id
    )

    create(
      :distribution,
      :taxon_concept_id => @species2.id,
      :geo_entity_id => madagascar.id
    )

    cites_lc = create_cites_II_addition(
      :taxon_concept => @genus,
      :effective_at => '2013-06-12',
      :is_current => true
    )

    create(
      :listing_distribution,
      :listing_change => cites_lc,
      :geo_entity => madagascar,
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
