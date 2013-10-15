# == Schema Information
#
# Table name: term_trade_codes_pairs
#
#  id                    :integer          not null, primary key
#  term_id               :integer
#  other_trade_code_id   :integer
#  other_trade_code_type :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'spec_helper'

describe TermTradeCodesPair do
  pending "add some examples to (or delete) #{__FILE__}"
end
