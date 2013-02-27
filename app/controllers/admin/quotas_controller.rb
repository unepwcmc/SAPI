class Admin::QuotasController < Admin::SimpleCrudController
  respond_to :js, :only => [:new, :edit, :create, :update]
  belongs_to :taxon_concept
  layout 'taxon_concepts'

  def new
    new! do
      load_lib_objects
    end
  end

  def create
    create! do |success, failure|
      success.js { render :template => 'admin/trade_codes/create' }
      failure.js { render :template => 'admin/trade_codes/new' }
    end
  end

  protected

  def load_lib_objects
    @units = Unit.order(:code)
    @terms = Term.order(:code)
    @source = Source.order(:code)
    @purposes = Purpose.order(:code)
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
      where(:is_current => true, :geo_entity_types => {:name => 'COUNTRY'})
  end

  def collection
    @quotas ||= end_of_association_chain.order('start_date').
      page(params[:page])
  end
end
