class TradeRestrictionSource < ActiveRecord::Base
  attr_accessible :source_id, :trade_restriction_id
  belongs_to :trade_restriction
  belongs_to :source, :class_name => 'TradeCode'
end
