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
  attr_accessible :common_name_id, :taxon_concept_id, :created_by_id,
    :updated_by_id, :name, :language_id
  attr_accessor :name, :language_id
  belongs_to :common_name
  belongs_to :taxon_concept

  validates :common_name_id, :presence => true

  before_validation do
    cname = CommonName.find_or_create_by(
      name: self.name, language_id: self.language_id)
    if cname.id && self.common_name_id != cname.id
      self.common_name_id = cname.id
    end
  end
end
