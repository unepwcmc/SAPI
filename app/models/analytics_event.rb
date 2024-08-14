# == Schema Information
#
# Table name: analytics_events
#
#  id         :integer          not null, primary key
#  event_name :string(255)
#  event_type :string(255)
#  created_at :datetime
#  updated_at :datetime
#
class AnalyticsEvent < ApplicationRecord
  # Can use enum once upgraded to > Rails 4.1
  EVENT_TYPES = %w[ download ]
  EVENT_NAMES = %w[ full_database_download ]

  validates :event_name, inclusion: { in: EVENT_NAMES }, presence: true
  validates :event_type, inclusion: { in: EVENT_TYPES }, presence: true

  # Used by `download_db` in app/controllers/cites_trade/home_controller.rb
  # attr_accessible :event_name, :event_type
end
