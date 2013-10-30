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
#

class TaxonConceptReference < ActiveRecord::Base
  attr_accessible :reference_id, :taxon_concept_id, :is_standard, :is_cascaded,
    :excluded_taxon_concepts_ids, :reference_attributes
  include PgArrayParser

  belongs_to :reference
  belongs_to :taxon_concept, :touch => true

  delegate :citation, :to => :reference

  accepts_nested_attributes_for :reference

  validates :reference_id, :uniqueness => { :scope => [:taxon_concept_id] }

  def excluded_taxon_concepts
    TaxonConcept.where(:id => self.excluded_taxon_concepts_ids.try(:split, ",")).
      order(:full_name)
  end

  def excluded_taxon_concepts_ids
    parse_pg_array(read_attribute(:excluded_taxon_concepts_ids)||"")
  end

  def excluded_taxon_concepts_ids=(ary)
    write_attribute(:excluded_taxon_concepts_ids, '{' + ary + '}' )
  end

end
