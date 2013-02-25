class Admin::QuotasController < Admin::SimpleCrudController
  respond_to :js, :only => [:new, :edit, :create, :update]
  belongs_to :taxon_concept
  layout 'taxon_concepts'

  def create
    create! do |success, failure|
      success.js { render :template => 'admin/trade_codes/create' }
      failure.js { render :template => 'admin/trade_codes/new' }
    end
  end

  protected

  def collection
    @quotas ||= end_of_association_chain.order('start_date').
      page(params[:page])
  end
end
