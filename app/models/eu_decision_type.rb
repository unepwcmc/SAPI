# == Schema Information
#
# Table name: eu_decision_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  tooltip    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EuDecisionType < ActiveRecord::Base
  attr_accessible :name, :tooltip, :is_suspension

  scope :opinions, where(:is_suspension => false)
end
