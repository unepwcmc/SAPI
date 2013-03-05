class Admin::QuotasController < Admin::SimpleCrudController
  belongs_to :taxon_concept
  before_filter :load_lib_objects

  layout 'taxon_concepts'

  def new
    new! do
      load_lib_objects
    end
  end

  def update
    update! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_quotas_url(params[:taxon_concept_id]),
        :notice => 'Operation successful'
      }
      failure.html {
        load_tags_and_geo_entities
        render 'new'
      }
    end
  end

  def create
    create! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_quotas_url(params[:taxon_concept_id]),
        :notice => 'Operation successful'
      }
      failure.html { render 'create' }
    end
  end

  protected

  def load_lib_objects
    @units = Unit.order(:code)
    @terms = Term.order(:code)
    @sources = Source.order(:code)
    @purposes = Purpose.order(:code)
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
      where(:is_current => true, :geo_entity_types => {:name => 'COUNTRY'})
  end

  def collection
    @quotas ||= end_of_association_chain.order('start_date').
      page(params[:page])
  end
end
