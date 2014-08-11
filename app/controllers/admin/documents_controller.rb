class Admin::DocumentsController < Admin::SimpleCrudController

  def index
    @event_types = ['CitesCop', 'EcSrg']
    @events = Event.where(type: @event_types)
  end

end
