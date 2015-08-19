class Api::V1::EventsController < ApplicationController

  def index
    @events = Event.
      select([:id, :name, :type]).
      where(type: Event.elibrary_event_types.map(&:name)).
      order(:published_at)
    render :json => @events,
      :each_serializer => Species::EventSerializer,
      :meta => {:total => @events.count}
  end

end
