shared_context "Panax ginseng" do
  let(:country){
    create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
  }
  let(:russia){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Russia',
      :iso_code2 => 'RU'
    )
  }
  let(:china){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'China',
      :iso_code2 => 'CN'
    )
  }
  before(:all) do
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Apiales'),
      :parent => cites_eu_plantae.reload # reload is needed for full name
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Araliaceae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Panax'),
      :parent => @family,
      :name_status => 'A'
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Ginseng'),
      :parent => @genus,
      :name_status => 'A'
    )

    a1 = create(
      :annotation,
      :symbol => '#3',
      :parent_symbol => 'CoP11',
      :full_note_en => 'generic'
    )

    a2 = create(
      :annotation,
      :full_note_en => 'specific',
      :display_in_index => true
    )

    cites_lc1 = create_cites_II_addition(
      :taxon_concept => @species,
      :effective_at => '2000-07-19',
      :hash_annotation_id => a1.id,
      :annotation_id => a2.id,
      :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => russia,
      :listing_change => cites_lc1,
      :is_party => false
    )
    eu_lc1 = create_eu_B_addition(
      :taxon_concept => @species,
      :effective_at => '2000-07-19',
      :hash_annotation_id => a1.id,
      :annotation_id => a2.id,
      :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => russia,
      :listing_change => eu_lc1,
      :is_party => false
    )

    [china, russia].each do |country|
      create(
        :distribution,
        :taxon_concept => @species,
        :geo_entity => country
      )
    end

    cms_designation
    Sapi.rebuild(:except => [:taxonomy])
    self.instance_variables.each do |t|
      var = self.instance_variable_get(t)
      if var.kind_of? TaxonConcept
        self.instance_variable_set(t,MTaxonConcept.find(var.id))
        self.instance_variable_get(t).reload
      end
    end
  end
end
