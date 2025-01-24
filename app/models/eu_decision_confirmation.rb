# == Schema Information
#
# Table name: eu_decision_confirmations
#
#  id             :integer          not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  eu_decision_id :integer
#  event_id       :integer
#
# Indexes
#
#  index_eu_decision_confirmations_on_eu_decision_id  (eu_decision_id)
#  index_eu_decision_confirmations_on_event_id        (event_id)
#
# Foreign Keys
#
#  eu_decision_confirmations_eu_decision_id_fk  (eu_decision_id => eu_decisions.id)
#  eu_decision_confirmations_event_id_fk        (event_id => events.id)
#

class EuDecisionConfirmation < ApplicationRecord
  # Relationship table between Event and EuDecision
  # attr_accessible :eu_decision_id, :event_id

  belongs_to :eu_decision
  belongs_to :event
end
