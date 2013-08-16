# == Schema Information
#
# Table name: eu_decision_confirmations
#
#  id             :integer          not null, primary key
#  eu_decision_id :integer
#  event_id       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class EuDecisionConfirmation < ActiveRecord::Base
  attr_accessible :eu_decision_id, :event_id

  belongs_to :eu_decision
end
