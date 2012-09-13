class TimelinesForTaxonConcept
  def initialize(taxon_concept_id)
    @taxon_concept_id = taxon_concept_id
    @listing_changes = ListingChange.select('listing_changes_view.*').from('listing_changes_view').
      where('listing_changes_view.taxon_concept_id' => taxon_concept_id)
    @timelines = {}
    @time_start = Time.new('1975-01-01')
    @time_end = Time.new("#{Time.now.year + 1}-01-01")
    generate_timelines

  end

  def generate_timelines
    total_time_span = @time_end - @time_start

    @listing_changes.each_with_index do |ch, idx|
      applicable_timelines = []
      applicable_timelines << ch.species_listing_name if [ChangeType::ADDITION, ChangeType::DELETION].include? ch.change_type_name
      applicable_timelines << "#{ch.species_listing_name}_#{ch.party_name}" if ch.party_name
      proportionate_time_span = ch.effective_at - @time_start
      position = (proportionate_time_span / total_time_span) * 100
      applicable_timelines.each do |tl|
        current_timeline = (@timelines[tl] ||= Timeline.new(:label => tl))
        timeline_event = TimelineEvent.new(
          :listing_change_id => ch.id,
          :pos => position
        )
        current_timeline.events << timeline_event
        #now add the interval:
        #an ADDITION, RESERVATION or RESERVATION WITHDRAWAL event is followed
        #by a protection period that extends until a another event occurs
        #find previous interval
        previous_interval = current_timeline.intervals.last
        if previous_interval
          previous_interval.end_pos = position
        end
        unless ch.change_type_name == 'DELETION'
          timeline_interval = TimelineInterval.new(
            :start_pos => position
          )
          current_timeline.intervals << timeline_interval
        end
      end
    end
    @timelines.each do |name, timeline|
      #close hanging intervals
      last_interval = timeline.intervals.last
      if last_interval && last_interval.end_pos.nil?
        last_interval.end_pos = 100
      end
    end
  end

  def to_s
    @listing_changes.each do |ch|
      puts "#{ch.id} #{ch.effective_at} #{ch.species_listing_name} #{ch.change_type_name} #{ch.party_name}"
    end
    @timelines.each do |name, timeline|
      puts name
      timeline.events.each do |event|
        puts "#{event.listing_change_id} #{event.pos}"
      end
      timeline.intervals.each do |interval|
        puts "#{interval.start_pos} - #{interval.end_pos}"
      end
    end
  end

  def to_json
    res = {
      :id => object_id,
      :taxon_concept_id => @taxon_concept_id,
      :listing_changes => @listing_changes.map do |ch| 
        {
          :id => ch.id,
          :effective_at => ch.effective_at,
          :change_type_name => ch.change_type_name,
          :species_listing_name => ch.species_listing_name,
          :notes => ch.notes
        }
      end
    }
    timelines_values = @timelines.values
    timelines = ['I', 'II', 'III'].each do |appdx|
      res["timelines_#{appdx}"] = {
        :main => @timelines[appdx],
        :per_party => timelines_values.select do |tl|
          tl.appendix == appdx && tl.party
        end.sort{ |t1, t2| t1.party <=> t2.party }
      }
    end
    res
  end

end