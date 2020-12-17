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
    :suspension, :srg_referral

  scope :opinions, -> { where('decision_type <> ?', EuDecisionType::SUSPENSION).
    order('UPPER(name) ASC') }
  scope :suspensions, -> { where(:decision_type => EuDecisionType::SUSPENSION).
    order('UPPER(name) ASC') }

  validates :name, presence: true, uniqueness: true
  validates :decision_type, presence: true

  has_many :eu_decisions

  def name_for_display
    !!(self.name =~ /^i+\)/) ? "(No opinion) #{self.name}" : self.name
  end

  private

  def dependent_objects_map
    {
      'EU decisions' => eu_decisions
    }
  end
end
