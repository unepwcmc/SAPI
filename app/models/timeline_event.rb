class TimelineEvent
  attr_accessor :listing_change_id, :pos
  #options to be passed:
  #:listing_change_id
  #:pos - position (%)
  def initialize(options)
    @listing_change_id = options[:listing_change_id]
    @pos = options[:pos]
  end
end