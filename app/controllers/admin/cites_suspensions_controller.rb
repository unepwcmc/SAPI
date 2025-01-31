class Admin::CitesSuspensionsController < Admin::StandardAuthorizationController
  before_action :load_lib_objects, only: [ :new, :edit ]

  def create
    create! do |success, failure|
      success.html do
        redirect_to admin_cites_suspensions_url,
          notice: 'Operation successful'
      end
      failure.html do
        load_lib_objects
        render 'new'
      end
    end
  end

  def update
    update! do |success, failure|
      success.html do
        redirect_to admin_cites_suspensions_url,
          notice: 'Operation successful'
      end
      failure.html do
        load_lib_objects
        render 'edit'
      end
    end
  end

protected

  def load_lib_objects
    @current_suspensions = CitesSuspension.where(
      is_current: true
    ).where(
      taxon_concept_id: nil
    )

    @units = Unit.order(:code)
    @terms = Term.order(:code)
    @sources = Source.order(:code)
    @purposes = Purpose.order(:code)
    @geo_entities = GeoEntity.order(:name_en).joins(
      :geo_entity_type
    ).where(
      is_current: true,
      geo_entity_types: { name: GeoEntityType::SETS[GeoEntityType::DEFAULT_SET] }
    )

    @suspension_notifications = CitesSuspensionNotification.select(
      [ :id, :name ]
    ).order(
      'effective_at DESC'
    )
  end

  def collection
    @cites_suspensions ||= end_of_association_chain.order(
      'start_date DESC'
    ).page(
      params[:page]
    ).search(
      params[:query]
    )
  end

private

  def cites_suspension_params
    params.require(:cites_suspension).permit(
      # attributes were in model `attr_accessible`.
      :start_notification_id, :end_notification_id,
      :applies_to_import, :end_date, :geo_entity_id, :is_current,
      :notes, :publication_date, :quota, :type,
      :start_date, :unit_id, :internal_notes,
      :nomenclature_note_en, :nomenclature_note_es, :nomenclature_note_fr,
      :created_by_id, :updated_by_id, :url,
      :taxon_concept_id,
      cites_suspension_confirmations_attributes: [
        :id, :cites_suspension_notification_id, :_destroy
      ],
      purpose_ids: [],
      term_ids: [],
      source_ids: []
    )
  end
end
