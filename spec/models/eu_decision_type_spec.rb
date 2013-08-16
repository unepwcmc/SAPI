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

require 'spec_helper'

describe EuDecisionType do
  pending "add some examples to (or delete) #{__FILE__}"
end
