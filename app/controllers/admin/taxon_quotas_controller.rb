class Admin::TaxonQuotasController < Admin::SimpleCrudController
  defaults resource_class: Quota,
    collection_name: 'quotas', instance_name: 'quota'
  belongs_to :taxon_concept

  before_action :load_lib_objects
  before_action :load_search, except: [ :destroy ]
  layout 'taxon_concepts'

  authorize_resource class: false

  def create
    create! do |success, failure|
      success.html do
        redirect_to admin_taxon_concept_quotas_url(params[:taxon_concept_id]),
          notice: 'Operation successful'
      end
      failure.html { render 'create' }
    end
  end
  def update
    update! do |success, failure|
      success.html do
        redirect_to admin_taxon_concept_quotas_url(params[:taxon_concept_id]),
          notice: 'Operation successful'
      end
      failure.html do
        load_lib_objects
        render 'new'
      end

      success.js { render 'create' }
      failure.js do
        load_lib_objects
        render 'new'
      end
    end
  end


  def destroy
    destroy! do |success, failure|
      success.html do
        redirect_to admin_taxon_concept_quotas_url(@taxon_concept),
          notice: 'Operation successful'
      end
    end
  end

protected

  def load_lib_objects
    @units = Unit.order(:code)
    @terms = Term.order(:code)
    @sources = Source.order(:code)
    @purposes = Purpose.order(:code)
    @geo_entities = GeoEntity.order(:name_en).joins(
      :geo_entity_type
    ).where(
      is_current: true,
      geo_entity_types: {
        name: GeoEntityType::SETS[GeoEntityType::DEFAULT_SET]
      }
    )
  end

  def collection
    @quotas ||= end_of_association_chain.joins(
      :geo_entity
    ).order(
      'start_date DESC, geo_entities.name_en ASC, notes ASC'
    ).page(params[:page])
  end

private

  def quota_params
    params.require(:quota).permit(
      :public_display, :end_date, :geo_entity_id, :is_current,
      :notes, :publication_date, :quota, :type,
      :start_date, :unit_id, :internal_notes,
      :nomenclature_note_en, :nomenclature_note_es, :nomenclature_note_fr,
      :created_by_id, :updated_by_id, :url,
      :taxon_concept_id,
      term_ids: [],
      source_ids: [],
      purpose_ids: []
    )
  end
end
