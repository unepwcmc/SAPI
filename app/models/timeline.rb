class Timeline
  attr_reader :appendix, :party, :events, :intervals
  def initialize(options)
    @appendix, @party = options[:label].split('_')
    @events = []
    @intervals = []
  end
end