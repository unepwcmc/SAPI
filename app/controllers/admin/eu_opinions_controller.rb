class Admin::EuOpinionsController < Admin::StandardAuthorizationController
  belongs_to :taxon_concept
  before_filter :load_lib_objects
  before_filter :load_search, :only => [:new, :index, :edit]

  layout 'taxon_concepts'

  def update
    update! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_eu_opinions_url(params[:taxon_concept_id]),
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
        redirect_to admin_taxon_concept_eu_opinions_url(params[:taxon_concept_id]),
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
    @terms = Term.order(:code)
    @sources = Source.order(:code)
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
      where(:geo_entity_types => { :name => GeoEntityType::SETS[GeoEntityType::DEFAULT_SET] })
    @eu_decision_types = EuDecisionType.opinions
    @srg_histories = SrgHistory.order(:name)
    @ec_srgs = Event.where("type = 'EcSrg' OR
      type = 'EuRegulation' AND name IN ('No 338/97', 'No 938/97', 'No 750/2013')"
    ).order("effective_at DESC")
    # this will only return intersessional docs
    @documents = Document.where("event_id IS NULL AND type = 'Document::CommissionNotes'")
                         .order('date DESC, title')
  end

  def collection
    @eu_opinions ||= end_of_association_chain.
      joins(:geo_entity).
      order('is_current DESC, start_date DESC,
        geo_entities.name_en ASC').
      page(params[:page])
  end
end
