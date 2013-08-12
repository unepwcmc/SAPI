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

require 'spec_helper'

describe EuDecisionConfirmation do
  pending "add some examples to (or delete) #{__FILE__}"
end
