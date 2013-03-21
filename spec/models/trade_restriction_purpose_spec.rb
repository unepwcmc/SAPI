# == Schema Information
#
# Table name: trade_restriction_purposes
#
#  id                   :integer          not null, primary key
#  trade_restriction_id :integer
#  purpose_id           :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'spec_helper'

describe TradeRestrictionPurpose do
  pending "add some examples to (or delete) #{__FILE__}"
end
