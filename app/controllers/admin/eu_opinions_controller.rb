class Admin::EuOpinionsController < Admin::StandardAuthorizationController
  belongs_to :taxon_concept
  before_action :load_lib_objects
  before_action :load_search, only: [ :new, :index, :edit ]

  layout 'taxon_concepts'

  def create
    create! do |success, failure|
      success.html do
        redirect_to admin_taxon_concept_eu_opinions_url(params[:taxon_concept_id]),
          notice: 'Operation successful'
      end
      failure.html do
        load_search
        render 'new'
      end
    end
  end
  def update
    update! do |success, failure|
      success.html do
        redirect_to admin_taxon_concept_eu_opinions_url(params[:taxon_concept_id]),
          notice: 'Operation successful'
      end
      failure.html do
        load_lib_objects
        load_search
        render 'new'
      end
    end
  end


  protected

  def load_lib_objects
    @terms = Term.order(:code)
    @sources = Source.order(:code)
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
      where(geo_entity_types: { name: GeoEntityType::SETS[GeoEntityType::DEFAULT_SET] })
    @eu_decision_types = EuDecisionType.opinions
    @srg_histories = SrgHistory.order(:name)
    @ec_srgs = Event.where("type = 'EcSrg' OR
      type = 'EuRegulation' AND name IN ('No 338/97', 'No 938/97', 'No 750/2013')"
    ).order('effective_at DESC')
    # this will only return intersessional docs
    @documents = Document.where("event_id IS NULL AND type = 'Document::CommissionNotes'").
      order('date DESC, title')
  end

  def collection
    @eu_opinions ||= end_of_association_chain.
      joins(:geo_entity).
      order('is_current DESC, start_date DESC,
        geo_entities.name_en ASC').
      page(params[:page])
  end

  private

  def eu_opinion_params
    params.require(:eu_opinion).permit(
      # attributes were in model `attr_accessible`.
      :document_id, :end_date, :end_event_id, :geo_entity_id, :internal_notes,
      :is_current, :notes, :start_date, :start_event_id, :eu_decision_type_id,
      :taxon_concept_id, :type, :conditions_apply, :term_id, :source_id,
      :nomenclature_note_en, :nomenclature_note_es, :nomenclature_note_fr,
      :created_by_id, :updated_by_id, :srg_history_id
    )
  end
end
