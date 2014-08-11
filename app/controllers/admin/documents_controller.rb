class Admin::DocumentsController < Admin::StandardAuthorizationController

  def index
    @event_types = ['CitesCop', 'EcSrg']
    @events = Event.where(type: @event_types)
  end

end
