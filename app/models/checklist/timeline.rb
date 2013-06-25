class Checklist::Timeline
  include ActiveModel::SerializerSupport
  attr_reader :id, :appendix, :party_id, :timeline_events, :timeline_intervals, :parties, :timelines
  def initialize(options)
    @id = object_id
    @appendix = options[:appendix]
    @party_id = options[:party_id]
    @timeline_events = []
    @timeline_intervals = []
    @parties = []
    @timelines = []
    @appendix = options[:appendix]
    @time_start = options[:start]
    @time_end = options[:end]
  end

  def add_event(event)
    proportionate_time_span = event.effective_at - @time_start
    position = (proportionate_time_span / (@time_end - @time_start)).round(2)
    event.pos = position
    if event.is_addition?
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
        interval = if idx < (timeline.timeline_events.size - 1)
          next_event = timeline.timeline_events[idx + 1]
          if !(event.is_deletion? && next_event.is_addition?)
            Checklist::TimelineInterval.new(
              :start_pos => event.pos,
              :end_pos => next_event.pos
            )
          end
        else
          add_final_interval = true
          if event.is_deletion?
            additions_no = timeline.timeline_events.select do |e|
              e.is_addition?
            end.count
            deletions_no = timeline.timeline_events.select do |e|
              e.is_deletion?
            end.count
            add_final_interval = (additions_no > deletions_no)
          elsif event.is_reservation_withdrawal?
            add_final_interval = false
          end

          if add_final_interval
            Checklist::TimelineInterval.new(
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
      #fetch existing party timeline
      @timelines[party_idx]
    else
      #create party timeline
      @parties << party_id
      party_timeline = Checklist::Timeline.new(
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
