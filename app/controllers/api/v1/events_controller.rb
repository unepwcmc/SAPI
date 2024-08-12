class Api::V1::EventsController < ApplicationController

  def index
    @events = Event.
      select([:id, :name, :type, :published_at]).
      where(type: Event.elibrary_event_types.map(&:name)).
      order(:type, published_at: :desc)
    render json: @events,
      each_serializer: Species::EventSerializer,
      meta: { total: @events.count(:all) }
  end

end
