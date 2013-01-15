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
#

require 'spec_helper'

describe TaxonRelationship do
  describe :has_opposite? do
    context 'a relationship with no opposite' do
      TaxonRelationship.delete_all
      TaxonRelationshipType.delete_all
      let(:taxon_relationship_type) {create(:taxon_relationship_type, :is_bidirectional => false)}
      let!(:taxon_relationship) { create(:taxon_relationship, :taxon_relationship_type_id => taxon_relationship_type.id) }
      specify { taxon_relationship.has_opposite?.should == false }
    end
    context 'with an opposite' do
      TaxonRelationship.delete_all
      TaxonRelationshipType.delete_all
      let(:taxon_relationship_type) {create(:taxon_relationship_type, :is_bidirectional => false)}
      let(:taxon_relationship) { create(:taxon_relationship, :taxon_relationship_type_id => taxon_relationship_type.id) }
      let!(:taxon_relationship2) { create(:taxon_relationship, 
                                          :taxon_concept_id => taxon_relationship.other_taxon_concept_id,
                                          :other_taxon_concept_id => taxon_relationship.taxon_concept_id,
                                          :taxon_relationship_type_id => taxon_relationship_type.id )}
      specify { taxon_relationship.has_opposite?.should == true }
    end
  end

  describe :after_create_create_opposite do
    context 'when creating a bidirectional relationship' do
      TaxonRelationship.delete_all
      TaxonRelationshipType.delete_all
      let(:taxon_relationship_type) {create(:taxon_relationship_type, :is_bidirectional => true)}
      let!(:taxon_relationship) { create(:taxon_relationship, :taxon_relationship_type_id => taxon_relationship_type.id) }
      specify { taxon_relationship.has_opposite?.should == true }
    end

    context 'when creating a non bidirectional relationship' do
      TaxonRelationship.delete_all
      TaxonRelationshipType.delete_all
      let(:taxon_relationship_type) {create(:taxon_relationship_type, :is_bidirectional => false)}
      let!(:taxon_relationship) { create(:taxon_relationship, :taxon_relationship_type_id => taxon_relationship_type.id) }
      specify { taxon_relationship.has_opposite?.should == false }
    end
  end
end
