class TimelineInterval
  attr_accessor :start_pos, :end_pos
  #options to be passed:
  #:start_pos - start position (%)
  #:end_pos - end position (%)
  def initialize(options)
    @start_pos = options[:start_pos]
    @end_pos = options[:end_pos]
  end
end