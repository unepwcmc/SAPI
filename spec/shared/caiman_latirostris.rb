#Encoding: utf-8
shared_context "Caiman latirostris" do
  let(:en){ create(:language, :name => 'English', :iso_code1 => 'EN', :iso_code3 => 'ENG') }
  let(:country){
    create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
  }
  let(:argentina){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Argentina',
      :iso_code2 => 'AR'
    )
  }
  let(:has_synonym){
    create(
      :taxon_relationship_type, :name => TaxonRelationshipType::HAS_SYNONYM
    )
  }
  before(:all) do
    create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
    @order = create_cites_eu_order(
      :taxon_name => create(:taxon_name, :scientific_name => 'Crocodylia'),
      :parent => cites_eu_reptilia
    )
    @family = create_cites_eu_family(
      :taxon_name => create(:taxon_name, :scientific_name => 'Alligatoridae'),
      :parent => @order
    )
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Caiman'),
      :parent => @family
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'Latirostris'),
      :parent => @genus,
      :name_status => 'A',
      :common_names => [
        create(:common_name, :name => 'Broad-nosed Caiman', :language => en),
        create(:common_name, :name => 'Broad-snouted Caiman', :language => en)
      ]
    )
    @species1 = create_cites_eu_species(
      :full_name => 'Alligator cynocephalus',
      :name_status => 'S'
    )

    create(
      :taxon_relationship,
      :taxon_relationship_type => has_synonym,
      :taxon_concept => @species,
      :other_taxon_concept => @species1
    )

    @ref = create(
      :reference,
      :title => 'Schildkröte, Krokodile, Brückenechsen',
      :author => 'Wermuth, H. & Mertens, R.',
      :year => 1996
    )

    create(
      :taxon_concept_reference,
      :taxon_concept => @species,
      :reference => @ref,
      :is_standard => true
    )

    create_cites_II_addition(
      :taxon_concept => @order,
      :effective_at => '1977-02-04',
      :is_current => true
    )
    create_eu_B_addition(
      :taxon_concept => @order,
      :effective_at => '1977-02-04',
      :is_current => true
    )

    create_cites_I_addition(
     :taxon_concept => @species,
     :effective_at => '1975-07-01',
     :is_current => true
    )
    create_eu_A_addition(
     :taxon_concept => @species,
     :effective_at => '1975-07-01',
     :is_current => true
    )
    a1 = create(
      :annotation,
      :full_note_en => 'Population of AR; included in CROCODYLIA spp.',
      :display_in_index => true
    )
    cites_lc1 = create_cites_II_addition(
     :taxon_concept => @species,
     :annotation_id => a1.id,
     :effective_at => '1997-09-18',
     :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => argentina,
      :listing_change => cites_lc1,
      :is_party => false
    )
    eu_lc1 = create_eu_B_addition(
     :taxon_concept => @species,
     :annotation_id => a1.id,
     :effective_at => '1997-09-18',
     :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => argentina,
      :listing_change => eu_lc1,
      :is_party => false
    )

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
