require 'spec_helper'

describe TaxonRelationship do
  context "when synonymy" do
    let(:parent){
      create(
        :genus,
        :taxon_name => create(:taxon_name, :scientific_name => 'Lolcatus')
      )
    }
    let!(:tc){
      create(
        :species,
        :parent_id => parent.id,
        :taxon_name => create(:taxon_name, :scientific_name => 'lolatus')
      )
    }
    let!(:another_tc){
      create(
        :species,
        :parent_id => parent.id,
        :taxon_name => create(:taxon_name, :scientific_name => 'lolcatus')
      )
    }
    let(:synonym_attributes){
      build_tc_attributes(
        :species,
        :name_status => 'S',
        :author_year => 'Hemulen 2013',
        :full_name => 'Lolcatus lolus'
      )
    }
    let(:another_synonym_attributes){
      build_tc_attributes(
        :species,
        :name_status => 'S',
        :author_year => 'Hemulen 2013',
        :full_name => 'Lolcatus lolatus'
      )
    }
    let(:synonymy_rel){
      build(
        :has_synonym,
        :taxon_concept_id => tc.id,
        :other_taxon_concept_id => nil,
        :other_taxon_concept_attributes => synonym_attributes
      )
    }
    let(:another_synonymy_rel){
      build(
        :has_synonym,
        :taxon_concept_id => another_tc.id,
        :other_taxon_concept_id => nil,
        :other_taxon_concept_attributes => synonym_attributes
      )
    }
    specify {
      synonymy_rel.save
      tc.synonyms.map(&:full_name).should include('Lolcatus lolus')
    }
    specify{
      lambda do
        synonymy_rel.save
      end.should change(TaxonConcept, :count).by(1)
    }
    specify{
      lambda do
        synonymy_rel.save
        another_synonymy_rel.save
      end.should change(TaxonConcept, :count).by(1)
    }
    specify{
      synonymy_rel.save
      another_synonymy_rel.save
      another_tc.synonyms.map(&:full_name).should include('Lolcatus lolus')
    }
    specify{
      synonymy_rel.save
      another_synonymy_rel.save
      synonymy_rel.other_taxon_concept_attributes = another_synonym_attributes
      synonymy_rel.save
      tc.synonyms.map(&:full_name).should include('Lolcatus lolatus')
      another_tc.synonyms.map(&:full_name).should include('Lolcatus lolus')
    }
  end
end