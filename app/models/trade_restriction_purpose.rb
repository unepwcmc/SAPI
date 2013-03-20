class TradeRestrictionPurpose < ActiveRecord::Base
  attr_accessible :purpose_id, :trade_restriction_id
  belongs_to :trade_restriction
  belongs_to :purpose, :class_name => 'TradeCode'
end
