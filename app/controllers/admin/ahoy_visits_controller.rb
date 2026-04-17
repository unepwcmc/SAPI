class Admin::AhoyVisitsController < Admin::SimpleCrudController
  authorize_resource class: 'Ahoy::Visit'

  def index
    @ahoy_visits = Ahoy::Visit.order(started_at: :desc).page(params[:page])
  end
end
