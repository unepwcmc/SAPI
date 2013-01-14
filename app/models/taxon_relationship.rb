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

class TaxonRelationship < ActiveRecord::Base
  attr_accessible :taxon_concept_id, :other_taxon_concept_id, :taxon_relationship_type_id
  belongs_to :taxon_relationship_type
  belongs_to :taxon_concept
  belongs_to :other_taxon_concept, :class_name => 'TaxonConcept'

  validate :taxon_concept_id, :uniqueness => { :scope => [:taxon_relationship_type_id, :other_taxon_concept_id] }
  delegate :is_bidirectional?, :to => :taxon_relationship_type

  before_destroy :destroy_opposite

  def create_opposite
    TaxonRelationship.create(
      :taxon_concept_id => self.other_taxon_concept_id,
      :other_taxon_concept_id => self.taxon_concept_id,
      :taxon_relationship_type_id => self.taxon_relationship_type_id)
  end

  private
  def destroy_opposite
    TaxonRelationship.where(
        :taxon_concept_id => self.other_taxon_concept_id,
        :other_taxon_concept_id => self.taxon_concept_id,
        :taxon_relationship_type_id => self.taxon_relationship_type_id).
      delete_all
  end
end
