class Checklist::Timeline
  include ActiveModel::SerializerSupport
  attr_reader :id, :appendix, :party_id, :timeline_events, :timeline_intervals,
    :parties, :timelines, :continues_in_present, :has_nested_timelines
  def initialize(options)
    @taxon_concept_id = options[:taxon_concept_id]
    @appendix = options[:appendix]
    @party_id = options[:party_id]
    @timeline_events = []
    @timeline_intervals = []
    @parties = []
    @timelines = []
    @time_start = options[:start]
    @time_end = options[:end]
    @current = options[:current]
    @id = (@appendix.length << 16) + (@taxon_concept_id << 8) + (@party_id || 0)
  end

  def has_events?
    !@timeline_events.empty?
  end

  def add_event(event)
    proportionate_time_span = event.effective_at - @time_start
    position = (proportionate_time_span / (@time_end - @time_start)).round(2)
    event.pos = position
    if event.is_addition? # TODO: inclusion event with appendix change
      add_addition_event(event)
    elsif event.is_deletion?
      add_deletion_event(event)
    elsif event.is_reservation? || event.is_reservation_withdrawal?
      add_reservation_event(event)
    end
  end

  def add_addition_event(event)
    @timeline_events << event
  end

  def add_deletion_event(event)
    @timeline_events << event
  end

  def add_reservation_event(event)
    @has_nested_timelines = true
    get_party_timeline(event.party_id).timeline_events << event
  end

  def change_consecutive_additions_to_amendments
    (@timelines + [self]).flatten.each do |timeline|
      prev_event = nil
      timeline.timeline_events.each_with_index do |event, idx|
        if prev_event && (
          prev_event.is_addition? ||
            prev_event.change_type_name == 'AMENDMENT'
          ) &&
          event.is_addition? &&
          (event.party_id.nil? || event.party_id == prev_event.party_id)
          event.change_type_name = 'AMENDMENT'
        end
        prev_event = event
      end
    end
  end

  def add_intervals
    (@timelines + [self]).flatten.each do |timeline|
      timeline.timeline_events.each_with_index do |event, idx|
        interval =
          if idx < (timeline.timeline_events.size - 1)
            next_event = timeline.timeline_events[idx + 1]
            if !(
              event.is_deletion? && next_event.is_addition? ||
              event.is_reservation_withdrawal? && next_event.is_reservation?
              )
              Checklist::TimelineInterval.new(
                :taxon_concept_id => @taxon_concept_id,
                :listing_change_id => event.id,
                :start_pos => event.pos,
                :end_pos => next_event.pos
              )
            end
          else
            # the meaning of @current: there is a current listing in this appdx
            # this is to ensure an appdx III deletion does not terminate
            # the timeline if appdx III is still current
            if (event.is_addition? || event.is_amendment? || event.is_deletion?) &&
              @current || event.is_reservation? && event.is_current
              @continues_in_present = true
              Checklist::TimelineInterval.new(
                :taxon_concept_id => @taxon_concept_id,
                :listing_change_id => event.id,
                :start_pos => event.pos,
                :end_pos => 1
              )
            end
          end
        timeline.timeline_intervals << interval if interval
      end
    end
  end

  def get_party_timeline(party_id)
    unless (party_idx = @parties.index(party_id)).nil?
      # fetch existing party timeline
      @timelines[party_idx]
    else
      # create party timeline
      @parties << party_id
      party_timeline = Checklist::Timeline.new(
        :taxon_concept_id => @taxon_concept_id,
        :appendix => appendix,
        :party_id => party_id
      )
      @timelines << party_timeline
      party_timeline
    end
  end

  def party
    @party_id
  end

end
