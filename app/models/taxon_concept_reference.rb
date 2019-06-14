# == Schema Information
#
# Table name: taxon_concept_references
#
#  id                          :integer          not null, primary key
#  taxon_concept_id            :integer          not null
#  reference_id                :integer          not null
#  is_standard                 :boolean          default(FALSE), not null
#  is_cascaded                 :boolean          default(FALSE), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  excluded_taxon_concepts_ids :string
#  created_by_id               :integer
#  updated_by_id               :integer
#

class TaxonConceptReference < ActiveRecord::Base
  track_who_does_it
  attr_accessible :reference_id, :taxon_concept_id, :is_standard, :is_cascaded,
    :excluded_taxon_concepts_ids, :reference_attributes,
    :created_by_id, :updated_by_id

  belongs_to :reference
  belongs_to :taxon_concept

  delegate :citation, :to => :reference

  accepts_nested_attributes_for :reference

  validates :reference_id, :uniqueness => { :scope => [:taxon_concept_id] }

  def excluded_taxon_concepts
    ids = excluded_taxon_concepts_ids.try(:split, ",")
    ids.flatten.present? ? TaxonConcept.where(id: ids).order(:full_name) : []
  end

  def excluded_taxon_concepts_ids
    (read_attribute(:excluded_taxon_concepts_ids) || []).compact
  end

  def excluded_taxon_concepts_ids=(ary)
    # Make sure ary won't be between double curly braces
    write_attribute(:excluded_taxon_concepts_ids, "{#{ary.delete('{}')}}")
  end

end
