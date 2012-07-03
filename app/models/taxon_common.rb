# == Schema Information
#
# Table name: taxon_commons
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer
#  common_name_id   :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class TaxonCommon < ActiveRecord::Base
  attr_accessible :common_name_id, :taxon_concept_id
  belongs_to :common_name
end
