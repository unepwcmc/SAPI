class Admin::CitesCaptivityProcessesController < Admin::SimpleCrudController
  belongs_to :taxon_concept
  before_filter :load_lib_objects
  before_filter :load_search, :only => [:new, :index, :edit]
  layout 'taxon_concepts'

  def update
    update! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_cites_captivity_processes_url(params[:taxon_concept_id]),
        :notice => 'Operation successful'
      }
      failure.html {
        load_lib_objects
        load_search
        render 'new'
      }
    end
  end

  def create
    create! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_cites_captivity_processes_url(params[:taxon_concept_id]),
        :notice => 'Operation successful'
      }
      failure.html {
        load_search
        render 'new'
      }
    end
  end

  protected

  def load_lib_objects
    @units = Unit.order(:code)
    @terms = Term.order(:code)
    @sources = Source.order(:code)
    @purposes = Purpose.order(:code)
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
      where(:geo_entity_types => { :name => GeoEntityType::SETS[GeoEntityType::DEFAULT_SET] })
    @resolution = CitesCaptivityProcess::RESOLUTION
    @status = CitesCaptivityProcess::STATUS
    @meetings = Event.where("type IN ('CitesAc','CitesPc')"
    ).order("effective_at DESC")
  end

  def collection
    @cites_captivity_process ||= end_of_association_chain.
      joins(:geo_entity).
      order('is_current DESC, start_date DESC,
        geo_entities.name_en ASC').
      page(params[:page])
  end
end
