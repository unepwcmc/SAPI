class TimelinesForTaxonConcept
  include ActiveModel::Serializers::JSON
  attr_reader :id, :taxon_concept_id, :raw_timelines, :timelines,
    :timeline_years

  def initialize(taxon_concept_id)
    @taxon_concept_id = taxon_concept_id
    @id = @taxon_concept_id
    taxon_concept = MTaxonConcept.joins(:listing_changes).
      includes(:listing_changes).
      where(:"taxon_concepts_mview.id" => taxon_concept_id).first
    listing_changes = taxon_concept ? taxon_concept.listing_changes : []
    @timeline_events = listing_changes.map(&:to_timeline_event)
    @time_start = Time.new('1975-01-01')
    @time_end = Time.new("#{Time.now.year + 1}-01-01")
    generate_timelines
    generate_timeline_years
  end

  # this is required for JSON serialisation on non-AR model
  # for some reason keys can't be symbols
  def attributes
    {
      'id' => taxon_concept_id,
      'taxon_concept_id' => taxon_concept_id,
      'timeline_years' => timeline_years
    }
  end

  protected

  def generate_timelines
    @raw_timelines = {}
    ['I', 'II', 'III'].each do |species_listing_name|
      @raw_timelines[species_listing_name] = Timeline.new(
        :appendix => species_listing_name,
        :start => @time_start,
        :end => @time_end
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
    end
    @timelines = [@raw_timelines['I'], @raw_timelines['II'], @raw_timelines['III']]
  end

  def generate_timeline_years
    @timeline_years = @time_start.year.step((@time_end.year - @time_end.year % 5 + 5), 5).
      to_a.map do |year|
        {
          :id => year,
          :year => year,
          :pos => ((Time.new("#{year}-01-01") - @time_start) / (@time_end - @time_start)).round(2)
        }
      end
  end

end
