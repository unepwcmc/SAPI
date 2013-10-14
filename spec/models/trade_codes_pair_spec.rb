# == Schema Information
#
# Table name: trade_codes_pairs
#
#  id                    :integer          not null, primary key
#  trade_code_id         :integer
#  trade_code_type       :string(255)
#  other_trade_code_id   :integer
#  other_trade_code_type :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'spec_helper'

describe TradeCodesPair do
  pending "add some examples to (or delete) #{__FILE__}"
end
