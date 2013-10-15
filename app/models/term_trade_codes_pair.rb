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

class TermTradeCodesPair < ActiveRecord::Base
  attr_accessible :other_trade_code_id, :other_trade_code_type, :term_id
end
