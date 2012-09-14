class Timeline
  attr_reader :appendix, :party, :timeline_events, :timeline_intervals
  def initialize(options)
    @id = object_id
    @appendix, @party = options[:label].split('_')
    @timeline_events = []
    @timeline_intervals = []
  end
end