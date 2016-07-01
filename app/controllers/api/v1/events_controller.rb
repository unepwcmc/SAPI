class Api::V1::EventsController < ApplicationController

  def index
    @events = Event.
      select([:id, :name, :type, :published_at]).
      where(type: Event.elibrary_event_types.map(&:name)).
      order('type, published_at DESC')
    render :json => @events,
      :each_serializer => Species::EventSerializer,
      :meta => { :total => @events.count }
  end

end
