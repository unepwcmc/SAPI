class AnalyticsEvent < ActiveRecord::Base
  # Can use enum once upgraded to > Rails 4.1
  EVENT_TYPES = %w( download )
  EVENT_NAMES = %w( full_database_download )

  validates :event_name, inclusion: { in: EVENT_NAMES }, presence: true
  validates :event_type, inclusion: { in: EVENT_TYPES }, presence: true

  attr_accessible :event_name, :event_type
end
