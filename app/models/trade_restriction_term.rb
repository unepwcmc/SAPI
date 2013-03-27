# == Schema Information
#
# Table name: trade_restriction_terms
#
#  id                   :integer          not null, primary key
#  trade_restriction_id :integer
#  term_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class TradeRestrictionTerm < ActiveRecord::Base
  attr_accessible :term_id, :trade_restriction_id
  belongs_to :trade_restriction
  belongs_to :term, :class_name => 'TradeCode'
end
