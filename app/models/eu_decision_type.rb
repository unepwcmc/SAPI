# == Schema Information
#
# Table name: eu_decision_types
#
#  id            :integer          not null, primary key
#  decision_type :string(255)
#  name          :string(255)
#  tooltip       :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_eu_decision_types_on_name  (name) UNIQUE
#

class EuDecisionType < ApplicationRecord
  include Deletable

  # Migrated to controller (Strong Parameters)
  # attr_accessible :name, :tooltip, :decision_type
  include Dictionary
  build_dictionary :negative_opinion, :positive_opinion, :no_opinion,
    :suspension, :srg_referral

  scope :opinions, -> { where.not(decision_type: EuDecisionType::SUSPENSION).
    order(Arel.sql('UPPER(name) ASC')) }
  scope :suspensions, -> { where(decision_type: EuDecisionType::SUSPENSION).
    order(Arel.sql('UPPER(name) ASC')) }

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
