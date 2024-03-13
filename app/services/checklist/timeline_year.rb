class Checklist::TimelineYear
  include ActiveModel::SerializerSupport
  attr_accessor :id, :year, :pos
  # options to be passed:
  #:year - year on the timeline
  #:pos - position (%)
  def initialize(options)
    @id = (options[:taxon_concept_id] << 8) + options[:year]
    @year = options[:year]
    @pos = options[:pos]
  end
end
