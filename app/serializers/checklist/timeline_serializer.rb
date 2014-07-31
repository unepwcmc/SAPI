class Checklist::TimelineSerializer < ActiveModel::Serializer
  attributes :id, :appendix, :party, :parties, :continues_in_present,
    :has_nested_timelines
  has_many :timeline_events, :timeline_intervals, :timelines
end
