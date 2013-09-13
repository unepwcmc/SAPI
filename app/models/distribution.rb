# == Schema Information
#
# Table name: distributions
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer          not null
#  geo_entity_id    :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Distribution < ActiveRecord::Base
  attr_accessible :geo_entity_id, :taxon_concept_id, :tag_list, :references_attributes
  acts_as_taggable

  belongs_to :geo_entity
  belongs_to :taxon_concept, :touch => true
  has_many :distribution_references
  has_and_belongs_to_many :references, :join_table => :distribution_references
  accepts_nested_attributes_for :references, :allow_destroy => true

  validates :taxon_concept_id, :uniqueness => { :scope => :geo_entity_id, :message => 'already has this distribution' }

  def add_existing_references ids
    reference_ids = ids.split(",")

    reference_ids.each do |r|
      reference = Reference.find(r)
      unless reference.nil?
        self.distribution_references.
          create({
          :distribution_id => self.id,
          :reference_id => reference.id
        })
      end
    end
  end
end
