class Checklist::TimelineInterval
  include ActiveModel::SerializerSupport
  attr_accessor :id, :start_pos, :end_pos
  # options to be passed:
  #:start_pos - start position (%)
  #:end_pos - end position (%)
  def initialize(options)
    @id = (options[:taxon_concept_id] << 8) + options[:listing_change_id]
    @start_pos = options[:start_pos]
    @end_pos = options[:end_pos]
  end
end
