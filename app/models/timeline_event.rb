class TimelineEvent
  attr_accessor :listing_change_id, :pos
  #options to be passed:
  #:listing_change_id
  #:pos - position (%)
  def initialize(options)
    @id = object_id
    @pos = options[:pos]
    @change_type_name = options[:change_type_name]
    @appendix = options[:appendix]
    @effective_at = options[:effective_at]
  end
end