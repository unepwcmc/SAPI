# == Schema Information
#
# Table name: eu_decision_types
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  tooltip       :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  decision_type :string(255)
#

class EuDecisionType < ActiveRecord::Base
  attr_accessible :name, :tooltip, :decision_type
  include Dictionary
  build_dictionary :negative_opinion, :positive_opinion, :no_opinion,
    :suspension

  scope :opinions, where('decision_type <> ?', EuDecisionType::SUSPENSION).
    order('UPPER(name) ASC')
  scope :suspensions, where(:decision_type => EuDecisionType::SUSPENSION).
    order('UPPER(name) ASC')

  validates :name, presence: true, uniqueness: true
  validates :decision_type, presence: true

  has_many :eu_decisions

  def can_be_deleted?
    eu_decisions.count == 0
  end
end
