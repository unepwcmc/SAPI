# == Schema Information
#
# Table name: taxon_commons
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer          not null
#  common_name_id   :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  updated_by_id    :interger
#  created_by_id    :interger
#

class TaxonCommon < ActiveRecord::Base
  track_who_does_it
  attr_accessible :common_name_id, :taxon_concept_id, :common_name, 
    :common_name_attributes, :created_by_id, :updated_by_id
  belongs_to :common_name
  belongs_to :taxon_concept, :touch => true
  accepts_nested_attributes_for :common_name
end
