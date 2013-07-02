class Checklist::TimelineYearSerializer < ActiveModel::Serializer
  attributes :id, :year, :pos
end
