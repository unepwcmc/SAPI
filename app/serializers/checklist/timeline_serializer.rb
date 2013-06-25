class Checklist::TimelineSerializer < ActiveModel::Serializer
  attributes :id, :appendix, :party, :parties
  has_many :timeline_events, :timeline_intervals, :timelines
end
