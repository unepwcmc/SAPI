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

class TradeCodesPair < ActiveRecord::Base
  attr_accessible :other_trade_code_id, :other_trade_code_type, :trade_code_id, :trade_code_type
end
