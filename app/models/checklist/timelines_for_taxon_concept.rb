class Checklist::TimelinesForTaxonConcept
  include ActiveModel::SerializerSupport
  attr_reader :id, :taxon_concept_id, :raw_timelines, :timelines,
    :timeline_years, :has_descendant_timelines, :has_events, :has_reservations

  def initialize(taxon_concept)
    @taxon_concept_id = taxon_concept.id
    @id = @taxon_concept_id
    listing_changes = taxon_concept.cites_listing_changes.where(
      :show_in_timeline => true
    ).order(:effective_at)
    @current_appendices = listing_changes.where(
      :is_current => true,
      :change_type_name => ChangeType::ADDITION
    ).map(&:species_listing_name)
    @timeline_events = listing_changes.map(&:to_timeline_event)
    @has_descendant_timelines = taxon_concept.cites_listed_descendants
    @has_events = !@timeline_events.empty?
    @time_start = Time.new('1975-01-01')
    @time_end = Time.new("#{Time.now.year + 2}-01-01")
    generate_timelines
    generate_timeline_years
  end

  protected

  def generate_timelines
    @raw_timelines = {}
    ['I', 'II', 'III'].each do |species_listing_name|
      @raw_timelines[species_listing_name] = Checklist::Timeline.new(
        :taxon_concept_id => @taxon_concept_id,
        :appendix => species_listing_name,
        :start => @time_start,
        :end => @time_end,
        :current => @current_appendices.include?(species_listing_name)
      )
    end
    @timeline_events.each do |timeline_event|
      species_listing_name = timeline_event.species_listing_name ||
        (
          timeline_event.party_id &&
          timeline_event.is_deletion? &&
          'III'
        )
      @raw_timelines[species_listing_name] &&
      @raw_timelines[species_listing_name].add_event(timeline_event)
    end
    @raw_timelines.values.each do |t|
      t.change_consecutive_additions_to_amendments
      t.add_intervals
      @has_reservations = true if t.has_nested_timelines
    end
    @timelines = [@raw_timelines['I'], @raw_timelines['II'], @raw_timelines['III']]
  end

  def generate_timeline_years
    @timeline_years = @time_start.year.step((@time_end.year - @time_end.year % 5 + 5), 5).
      to_a.map do |year|
        Checklist::TimelineYear.new({
          :taxon_concept_id => @taxon_concept_id,
          :year => year,
          :pos => ((Time.new("#{year}-01-01") - @time_start) / (@time_end - @time_start)).round(2)
        })
      end
  end

end
