class Admin::AhoyEventsController < Admin::SimpleCrudController
  authorize_resource :class => 'Ahoy::Event'

  def index
    @ahoy_events = Ahoy::Event.order('time DESC').page(params[:page])
  end
end
