# == Schema Information
#
# Table name: taxon_relationships
#
#  id                         :integer          not null, primary key
#  taxon_concept_id           :integer          not null
#  other_taxon_concept_id     :integer          not null
#  taxon_relationship_type_id :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  created_by_id              :integer
#  updated_by_id              :integer
#

require 'spec_helper'

describe TaxonRelationship do
  describe :has_opposite? do
    context 'a relationship with no opposite' do
      let(:taxon_relationship_type) { create(:taxon_relationship_type, :is_bidirectional => false) }
      let!(:taxon_relationship) { create(:taxon_relationship, :taxon_relationship_type_id => taxon_relationship_type.id) }
      specify { taxon_relationship.has_opposite?.should == false }
    end
    context 'with an opposite' do
      let(:taxon_relationship_type) { create(:taxon_relationship_type, :is_bidirectional => true) }
      let(:taxon_relationship) { create(:taxon_relationship, :taxon_relationship_type_id => taxon_relationship_type.id) }
      specify { taxon_relationship.has_opposite?.should == true }
    end
  end

  describe :after_create_create_opposite do
    context 'when creating a bidirectional relationship' do
      let(:taxon_relationship_type) { create(:taxon_relationship_type, :is_bidirectional => true) }
      let!(:taxon_relationship) { create(:taxon_relationship, :taxon_relationship_type_id => taxon_relationship_type.id) }
      specify { taxon_relationship.has_opposite?.should == true }
    end

    context 'when creating a non bidirectional relationship' do
      let(:taxon_relationship_type) { create(:taxon_relationship_type, :is_bidirectional => false) }
      let!(:taxon_relationship) { create(:taxon_relationship, :taxon_relationship_type_id => taxon_relationship_type.id) }
      specify { taxon_relationship.has_opposite?.should == false }
    end
  end

  describe :validate_uniqueness_taxon_concept_id do
    context 'adding a duplicate relationship between the same taxon_concepts' do
      let(:taxonomy) { create(:taxonomy) }
      let(:taxonomy2) { create(:taxonomy) }
      let(:taxon_concept) { create(:taxon_concept, :taxonomy_id => taxonomy.id) }
      let(:taxon_concept2) { create(:taxon_concept, :taxonomy_id => taxonomy2.id) }
      let(:taxon_relationship_type) { create(:taxon_relationship_type) }
      let!(:taxon_relationship) {
        create(:taxon_relationship,
          :taxon_concept_id => taxon_concept.id,
          :other_taxon_concept_id => taxon_concept2.id,
          :taxon_relationship_type_id => taxon_relationship_type.id
        )
      }
      let(:taxon_relationship2) {
        build(:taxon_relationship,
          :taxon_concept_id => taxon_concept.id,
          :other_taxon_concept_id => taxon_concept2.id,
          :taxon_relationship_type_id => taxon_relationship_type.id
        )
      }
      specify { taxon_relationship2.valid? == false }
    end
  end

  describe :validate_intertaxonomic_relationship_uniqueness do
    context "adding an intertaxonomic relationship between taxon concepts that are already related (A -> B)" do
      let(:taxonomy) { create(:taxonomy) }
      let(:taxonomy2) { create(:taxonomy) }
      let(:taxon_concept) { create(:taxon_concept, :taxonomy_id => taxonomy.id) }
      let(:taxon_concept2) { create(:taxon_concept, :taxonomy_id => taxonomy2.id) }
      let(:taxon_relationship_type) { create(:taxon_relationship_type, :is_intertaxonomic => true) }
      let(:taxon_relationship_type2) { create(:taxon_relationship_type, :is_intertaxonomic => true) }
      let!(:taxon_relationship) {
        create(:taxon_relationship,
          :taxon_concept_id => taxon_concept.id,
          :other_taxon_concept_id => taxon_concept2.id,
          :taxon_relationship_type_id => taxon_relationship_type.id
        )
      }
      let(:taxon_relationship2) {
        build(:taxon_relationship,
          :taxon_concept_id => taxon_concept.id,
          :other_taxon_concept_id => taxon_concept2.id,
          :taxon_relationship_type_id => taxon_relationship_type2.id
        )
      }
      specify {
        taxon_relationship2.valid?.should == false
      }
    end
    context "adding an intertaxonomic relationship between taxon concepts that are already related in the opposite direction (B -> A)" do
      let(:taxonomy) { create(:taxonomy) }
      let(:taxonomy2) { create(:taxonomy) }
      let(:taxon_concept) { create(:taxon_concept, :taxonomy_id => taxonomy.id) }
      let(:taxon_concept2) { create(:taxon_concept, :taxonomy_id => taxonomy2.id) }
      let(:taxon_relationship_type) { create(:taxon_relationship_type, :is_intertaxonomic => true) }
      let(:taxon_relationship_type2) { create(:taxon_relationship_type, :is_intertaxonomic => true) }
      let!(:taxon_relationship) {
        create(:taxon_relationship,
          :taxon_concept_id => taxon_concept.id,
          :other_taxon_concept_id => taxon_concept2.id,
          :taxon_relationship_type_id => taxon_relationship_type.id
        )
      }

      let(:taxon_relationship2) {
        build(:taxon_relationship,
          :taxon_concept_id => taxon_concept2.id,
          :other_taxon_concept_id => taxon_concept.id,
          :taxon_relationship_type_id => taxon_relationship_type2.id
        )
      }
      specify {
        taxon_relationship2.valid?.should == false
      }
    end
    context "adding an intertaxonomic relationship between taxon concepts that are not already related" do
      let(:taxonomy) { create(:taxonomy) }
      let(:taxonomy2) { create(:taxonomy) }
      let(:taxon_concept) { create(:taxon_concept, :taxonomy_id => taxonomy.id) }
      let(:taxon_concept2) { create(:taxon_concept, :taxonomy_id => taxonomy2.id) }
      let(:taxon_concept3) { create(:taxon_concept, :taxonomy_id => taxonomy2.id) }
      let(:taxon_relationship_type) { create(:taxon_relationship_type, :is_intertaxonomic => true) }
      let(:taxon_relationship_type2) { create(:taxon_relationship_type, :is_intertaxonomic => true) }
      let!(:taxon_relationship) {
        create(:taxon_relationship,
          :taxon_concept_id => taxon_concept.id,
          :other_taxon_concept_id => taxon_concept2.id,
          :taxon_relationship_type_id => taxon_relationship_type.id
        )
      }

      let(:taxon_relationship2) {
        build(:taxon_relationship,
          :taxon_concept_id => taxon_concept.id,
          :other_taxon_concept_id => taxon_concept3.id,
          :taxon_relationship_type_id => taxon_relationship_type2.id
        )
      }

      specify {
        taxon_relationship2.valid?.should == true
      }
    end
  end
end
