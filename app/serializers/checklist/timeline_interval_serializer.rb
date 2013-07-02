class Checklist::TimelineIntervalSerializer < ActiveModel::Serializer
  attributes :id, :start_pos, :end_pos
end
