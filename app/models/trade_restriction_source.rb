# == Schema Information
#
# Table name: trade_restriction_sources
#
#  id                   :integer          not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  created_by_id        :integer
#  source_id            :integer
#  trade_restriction_id :integer
#  updated_by_id        :integer
#
# Indexes
#
#  index_trade_restriction_sources_on_created_by_id         (created_by_id)
#  index_trade_restriction_sources_on_source_id             (source_id)
#  index_trade_restriction_sources_on_trade_restriction_id  (trade_restriction_id)
#  index_trade_restriction_sources_on_updated_by_id         (updated_by_id)
#
# Foreign Keys
#
#  trade_restriction_sources_created_by_id_fk      (created_by_id => users.id)
#  trade_restriction_sources_source_id             (source_id => trade_codes.id)
#  trade_restriction_sources_trade_restriction_id  (trade_restriction_id => trade_restrictions.id)
#  trade_restriction_sources_updated_by_id_fk      (updated_by_id => users.id)
#

class TradeRestrictionSource < ApplicationRecord
  include TrackWhoDoesIt
  # Relationship model between TradeCode(source) and TradeRestriction
  # attr_accessible :source_id, :trade_restriction_id

  belongs_to :trade_restriction
  belongs_to :source, class_name: 'TradeCode'
end
