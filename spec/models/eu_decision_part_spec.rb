# == Schema Information
#
# Table name: eu_decision_parts
#
#  id             :integer          not null, primary key
#  is_current     :boolean
#  source_id      :integer
#  term_id        :integer
#  eu_decision_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'spec_helper'

describe EuDecisionPart do
  pending "add some examples to (or delete) #{__FILE__}"
end
