require 'spec_helper'

describe TaxonRelationship do
  let(:hybrid_relationship_type){
    create(
      :taxon_relationship_type,
      :name => TaxonRelationshipType::HAS_HYBRID,
      :is_intertaxonomic => false,
      :is_bidirectional => false
    )
  }
  context "when hybrid" do
    let(:parent){
      create_cites_eu_genus(
        :taxon_name => create(:taxon_name, :scientific_name => 'Lolcatus')
      )
    }
    let!(:tc){
      create_cites_eu_species(
        :parent_id => parent.id,
        :taxon_name => create(:taxon_name, :scientific_name => 'lolatus')
      )
    }
    let!(:another_tc){
      create_cites_eu_species(
        :parent_id => parent.id,
        :taxon_name => create(:taxon_name, :scientific_name => 'lolcatus')
      )
    }
    let(:hybrid_attributes){
      build_tc_attributes(
        :taxon_concept,
        :taxonomy => cites_eu,
        :rank => species_rank,
        :name_status => 'H',
        :author_year => 'Hemulen 2013',
        :full_name => 'Lolcatus lolatus x lolcatus'
      )
    }
    let(:another_hybrid_attributes){
      build_tc_attributes(
        :taxon_concept,
        :taxonomy => cites_eu,
        :rank => species_rank,
        :name_status => 'H',
        :author_year => 'Hemulen 2013',
        :full_name => 'Lolcatus lolcatus x ?'
      )
    }
    let(:hybrid_rel){
      build(
        :taxon_relationship,
        :taxon_relationship_type => hybrid_relationship_type,
        :taxon_concept_id => tc.id,
        :other_taxon_concept_id => nil,
        :other_taxon_concept_attributes => hybrid_attributes
      )
    }
    let(:another_hybrid_rel){
      build(
        :taxon_relationship,
        :taxon_relationship_type => hybrid_relationship_type,
        :taxon_concept_id => another_tc.id,
        :other_taxon_concept_id => nil,
        :other_taxon_concept_attributes => hybrid_attributes
      )
    }
    specify {
      hybrid_rel.save
      tc.hybrids.map(&:full_name).should include('Lolcatus lolatus x lolcatus')
    }
    specify{
      lambda do
        hybrid_rel.save
      end.should change(TaxonConcept, :count).by(1)
    }
    specify{
      lambda do
        hybrid_rel.save
        another_hybrid_rel.save
      end.should change(TaxonConcept, :count).by(1)
    }
    specify{
      hybrid_rel.save
      another_hybrid_rel.save
      another_tc.hybrids.map(&:full_name).should include('Lolcatus lolatus x lolcatus')
    }
    specify{
      hybrid_rel.save
      another_hybrid_rel.save
      hybrid_rel.other_taxon_concept_attributes = another_hybrid_attributes
      hybrid_rel.save
      tc.hybrids.map(&:full_name).should include('Lolcatus lolcatus x ?')
      another_tc.hybrids.map(&:full_name).should include('Lolcatus lolatus x lolcatus')
    }
  end
end