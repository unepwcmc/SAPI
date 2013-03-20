class TradeRestrictionTerm < ActiveRecord::Base
  attr_accessible :term_id, :trade_restriction_id
  belongs_to :trade_restriction
  belongs_to :term, :class_name => 'TradeCode'
end
