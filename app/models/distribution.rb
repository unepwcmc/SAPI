# == Schema Information
#
# Table name: distributions
#
#  id               :integer         not null, primary key
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  taxon_concept_id :integer         not null
#

class Distribution < ActiveRecord::Base
  has_many :distribution_components
end
