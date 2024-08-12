# == Schema Information
#
# Table name: trade_restriction_terms
#
#  id                   :integer          not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  created_by_id        :integer
#  term_id              :integer
#  trade_restriction_id :integer
#  updated_by_id        :integer
#
# Foreign Keys
#
#  trade_restriction_terms_created_by_id_fk      (created_by_id => users.id)
#  trade_restriction_terms_term_id               (term_id => trade_codes.id)
#  trade_restriction_terms_trade_restriction_id  (trade_restriction_id => trade_restrictions.id)
#  trade_restriction_terms_updated_by_id_fk      (updated_by_id => users.id)
#

class TradeRestrictionTerm < ApplicationRecord
  include TrackWhoDoesIt
  # Relationship model between TradeCode(term) and TradeRestriction
  # attr_accessible :term_id, :trade_restriction_id
  belongs_to :trade_restriction
  belongs_to :term, :class_name => 'TradeCode'
end
