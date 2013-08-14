# == Schema Information
#
# Table name: eu_decision_types
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  tooltip       :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  is_suspension :boolean
#

class EuDecisionType < ActiveRecord::Base
  attr_accessible :name, :tooltip, :is_suspension

  scope :opinions, where(:is_suspension => false).
    order(:name)
  scope :suspensions, where(:is_suspension => true).
    order(:name)
end
