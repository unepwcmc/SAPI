# == Schema Information
#
# Table name: term_trade_codes_pairs
#
#  id              :integer          not null, primary key
#  term_id         :integer
#  trade_code_id   :integer
#  trade_code_type :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class TermTradeCodesPair < ActiveRecord::Base
  attr_accessible :trade_code_id, :trade_code_type, :term_id

  belongs_to :term, :class_name => "TradeCode"
  belongs_to :trade_code, :polymorphic => true
end
