# == Schema Information
#
# Table name: taxon_commons
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer          not null
#  common_name_id   :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  created_by_id    :integer
#  updated_by_id    :integer
#

class TaxonCommon < ActiveRecord::Base
  track_who_does_it
  attr_accessible :common_name_id, :taxon_concept_id, :common_name,
    :common_name_attributes, :created_by_id, :updated_by_id
  belongs_to :common_name
  belongs_to :taxon_concept
  accepts_nested_attributes_for :common_name

  before_validation do
    cname = self.common_name
    return unless cname.valid?

    if cname.new_record?
      #check if it exists or use the provided details
      self.common_name = CommonName.find_by_name_and_language_id(
        cname.name, cname.language_id) || cname
    elsif cname.changed? && TaxonCommon.where(:common_name_id => cname.id).count > 1
      #if changed and associated with multiple taxonConcepts, create a new
      #common name
      self.common_name = CommonName.create(
        :name => cname.name,
        :language_id => cname.language_id
      )
    end
    self.touch if cname.new_record? || cname.changed?
  end
end
