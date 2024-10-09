# == Schema Information
#
# Table name: trade_restriction_purposes
#
#  id                   :integer          not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  created_by_id        :integer
#  purpose_id           :integer
#  trade_restriction_id :integer
#  updated_by_id        :integer
#
# Foreign Keys
#
#  trade_restriction_purposes_created_by_id_fk      (created_by_id => users.id)
#  trade_restriction_purposes_purpose_id            (purpose_id => trade_codes.id)
#  trade_restriction_purposes_trade_restriction_id  (trade_restriction_id => trade_restrictions.id)
#  trade_restriction_purposes_updated_by_id_fk      (updated_by_id => users.id)
#

class TradeRestrictionPurpose < ApplicationRecord
  include TrackWhoDoesIt
  # Relationship model between TradeCode(purpose) and TradeRestriction
  # attr_accessible :purpose_id, :trade_restriction_id

  belongs_to :trade_restriction
  belongs_to :purpose, class_name: 'TradeCode'
end
