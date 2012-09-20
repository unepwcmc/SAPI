class Timeline
  attr_reader :appendix, :party, :timeline_events, :timeline_intervals, :parties, :timelines
  def initialize(options)
    @id = object_id
    @appendix = options[:appendix]
    @party = options[:party]
    @timeline_events = []
    @timeline_intervals = []
    @parties = []
    @timelines = []
  end
end