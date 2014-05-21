# == Schema Information
#
# Table name: trade_restriction_purposes
#
#  id                   :integer          not null, primary key
#  trade_restriction_id :integer
#  purpose_id           :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  created_by_id        :integer
#  updated_by_id        :integer
#

class TradeRestrictionPurpose < ActiveRecord::Base
  track_who_does_it
  attr_accessible :purpose_id, :trade_restriction_id
  belongs_to :trade_restriction
  belongs_to :purpose, :class_name => 'TradeCode'
end
