class Admin::AhoyVisitsController < Admin::SimpleCrudController
  authorize_resource :class => 'Ahoy::Visit'

  def index
    @ahoy_visits = Ahoy::Visit.order('started_at DESC').page(params[:page])
  end
end
