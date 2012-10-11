class TimelinesForTaxonConcept
  def initialize(taxon_concept_id)
    @taxon_concept_id = taxon_concept_id
    @listing_changes = MListingChange.select('listing_changes_mview.*').
      where('listing_changes_mview.taxon_concept_id' => taxon_concept_id)
    @timelines = {}
    ['I', 'II', 'III'].each do |appdx|
      @timelines[appdx] = Timeline.new(:appendix => appdx)
    end
    @time_start = Time.new('1975-01-01')
    @time_end = Time.new("#{Time.now.year + 1}-01-01")
    @total_time_span = @time_end - @time_start
    generate_timelines
    generate_timeline_years
  end

  def generate_timelines
    @listing_changes.each_with_index do |ch, idx|
      proportionate_time_span = ch.effective_at - @time_start
      position = (proportionate_time_span / @total_time_span).round(2)
      appendix = ch.species_listing_name
      party = (ch.party_id ? ch.party_id : nil)
      if appendix.nil? && party && ch.change_type_name == ChangeType::DELETION
        appendix = 'III'
      end
      current_timeline = @timelines[appendix]
      timeline_event = TimelineEvent.new(ch.listing_attributes)
      timeline_event.pos = position
      party_timeline = if party &&
        ![ChangeType::ADDITION, ChangeType::DELETION].include?(ch.change_type_name)
        unless (party_idx = current_timeline.parties.index(ch.party_name)).nil?
          #fetch existing party timeline
          current_timeline.timelines[party_idx]
        else
          #create party timeline
          current_timeline.parties << ch.party_name
          party_timeline = Timeline.new(
            :appendix => appendix,
            :party => party
          )
          current_timeline.timelines << party_timeline
          party_timeline
        end
      else
        nil
      end

      if ch.change_type_name == ChangeType::ADDITION
        if current_timeline
          current_timeline.timeline_events << timeline_event
        end
        if party_timeline
          party_timeline.timeline_events << timeline_event
        end
      elsif ch.change_type_name == ChangeType::DELETION
        unless current_timeline
          #add to every existing timeline
          @timelines.each do |appdx, timeline|
            unless timeline.timeline_events.empty?
              timeline.timeline_events << timeline_event
            end
          end
        else
          current_timeline.timeline_events << timeline_event
        end
        party_timelines =  if ch.species_listing_name == 'III'
          current_timeline.timelines
        else
          []
        end
        party_timelines << party_timeline if party_timeline
        party_timelines.each do |pt|
          pt.timeline_events << timeline_event
        end
      elsif ch.change_type_name == ChangeType::RESERVATION && party_timeline
        party_timeline.timeline_events << timeline_event
      elsif ch.change_type_name == ChangeType::RESERVATION_WITHDRAWAL && party_timeline
        party_timeline.timeline_events << timeline_event
      else
        puts "Unrecognized event type: #{ch.change_type_name}"
      end
    end
    generate_intervals
  end

  def generate_intervals
    @timelines.map do |appdx, timeline|
      timeline.timelines + [timeline]
    end.flatten.each do |timeline|
      timeline.timeline_events.each_with_index do |event, idx|
        interval = if idx < (timeline.timeline_events.size - 1)
          next_event = timeline.timeline_events[idx + 1]
          TimelineInterval.new(
            :start_pos => event.pos,
            :end_pos => next_event.pos
          )
        else
          if [ChangeType::ADDITION, ChangeType::RESERVATION].include? event.change_type_name
            TimelineInterval.new(
              :start_pos => event.pos,
              :end_pos => 1
            )
          else
            nil
          end
        end
        timeline.timeline_intervals << interval if interval
      end
    end
  end

  def generate_timeline_years
    @timeline_years = @time_start.year.step((@time_end.year - @time_end.year % 5 + 5), 5).
      to_a.map do |year|
        {
          :year => year,
          :pos => ((Time.new("#{year}-01-01") - @time_start) / @total_time_span).round(2)
        }
      end
  end

  def to_json
    {
      :id => @taxon_concept_id,
      :taxon_concept_id => @taxon_concept_id,
      :timelines => [@timelines['I'], @timelines['II'], @timelines['III']],
      :timeline_years => @timeline_years
    }
  end

end
