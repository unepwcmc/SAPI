#Encoding: utf-8
shared_context "Caiman latirostris" do

  let(:en){ 
   create(:language, :name => 'Spanish', :iso_code1 => 'ES', :iso_code3 => 'SPA')
   create(:language, :name => 'French', :iso_code1 => 'FR', :iso_code3 => 'FRA')   
   create(:language, :name => 'English', :iso_code1 => 'EN', :iso_code3 => 'ENG') 
  }
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
  let(:brazil){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Brazil',
      :iso_code2 => 'BR'
    )
  }
  let(:has_synonym){
    create(
      :taxon_relationship_type, :name => TaxonRelationshipType::HAS_SYNONYM
    )
  }
  before(:all) do
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

    create(:distribution, :taxon_concept_id => @species.id, :geo_entity_id => argentina.id)
    create(:distribution, :taxon_concept_id => @species.id, :geo_entity_id => brazil.id)

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
    create_cites_I_addition(
     :taxon_concept => @species,
     :effective_at => '1975-07-01',
     :is_current => true
    )
    a_I = create(
      :annotation,
      :full_note_en => 'All populations except AR',
      :display_in_index => true
    )
    a_II = create(
      :annotation,
      :full_note_en => 'Population of AR; included in CROCODYLIA spp.',
      :display_in_index => true
    )
    cites_lc = create_cites_II_addition(
     :taxon_concept => @species,
     :annotation_id => a_II.id,
     :effective_at => '1997-09-18',
     :inclusion_taxon_concept_id => @order.id,
     :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => argentina,
      :listing_change => cites_lc,
      :is_party => false
    )

    create_eu_A_addition(
     :taxon_concept => @species,
     :effective_at => '1997-06-01',
     :event => reg1997
    )
    create_eu_B_addition(
     :taxon_concept => @order,
     :effective_at => '2013-10-08',
     :event => reg2013,
     :is_current => true
    )
    eu_lc_b = create_eu_B_addition(
     :taxon_concept => @species,
     :annotation_id => a_II.id,
     :effective_at => '2013-10-08',
     :event => reg2013,
     :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => argentina,
      :listing_change => eu_lc_b,
      :is_party => false
    )
    eu_lc_a = create_eu_A_addition(
     :taxon_concept => @species,
     :annotation_id => a_I.id,
     :effective_at => '2013-10-08',
     :event => reg2013,
     :is_current => true
    )
    eu_lc_a_exception = create_eu_A_exception(
     :taxon_concept => @species,
     :effective_at => '2013-10-08',
     :event => reg2013,
     :parent_id => eu_lc_a.id,
     :is_current => true
    )
    create(
      :listing_distribution,
      :geo_entity => argentina,
      :listing_change => eu_lc_a_exception,
      :is_party => false
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
