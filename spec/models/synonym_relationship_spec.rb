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
        :taxon_name_attributes => {:scientific_name => 'lolcatus'}
      )
    }
    let(:synonym_attributes){
      build_attributes(
        :species,
        :name_status => 'S',
        :author_year => 'Hemulen 2013',
        :taxon_name_attributes => {:scientific_name => 'Lolcatus lolus'}
      ).delete_if { |k, v| %w(data listing notes lft rgt).include? k}
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
  end
end