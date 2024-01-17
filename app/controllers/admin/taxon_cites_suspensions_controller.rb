class Admin::TaxonCitesSuspensionsController < Admin::SimpleCrudController
  defaults :resource_class => CitesSuspension,
    :collection_name => 'cites_suspensions', :instance_name => 'cites_suspension'
  belongs_to :taxon_concept

  before_filter :load_lib_objects, :only => [:new, :edit]
  before_filter :load_search, :except => [:create, :destroy]
  layout 'taxon_concepts'

  authorize_resource :class => false

  def create
    create! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_cites_suspensions_url(@taxon_concept),
        :notice => 'Operation successful'
      }
      failure.html {
        load_lib_objects
        render 'new'
      }
    end
  end

  def update
    update! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_cites_suspensions_url(@taxon_concept),
        :notice => 'Operation successful'
      }
      failure.html {
        load_lib_objects
        render 'edit'
      }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_cites_suspensions_url(@taxon_concept),
        :notice => 'Operation successful'
      }
    end
  end

  def load_lib_objects
    @units = Unit.order(:code)
    @terms = Term.order(:code)
    @sources = Source.order(:code)
    @purposes = Purpose.order(:code)
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
      where(:is_current => true,
            :geo_entity_types => { :name => GeoEntityType::SETS[GeoEntityType::DEFAULT_SET] })
    @suspension_notifications = CitesSuspensionNotification.
      select([:id, :name]).
      order('effective_at DESC')
  end

  def collection
    @cites_suspensions ||= end_of_association_chain.page(params[:page])
  end

  private

  def cites_suspension_params
    params.require(:cites_suspension).permit(
      # attributes were in model `attr_accessible`.
      :start_notification_id, :end_notification_id,
      :applies_to_import, :end_date, :geo_entity_id, :is_current,
      :notes, :publication_date, :purpose_ids, :quota, :type,
      :source_ids, :start_date, :term_ids, :unit_id, :internal_notes,
      :nomenclature_note_en, :nomenclature_note_es, :nomenclature_note_fr,
      :created_by_id, :updated_by_id, :url,
      :taxon_concept_id,
      cites_suspension_confirmations_attributes: [
        :cites_suspension_notification_id, :id, :_destroy
      ]
    )
  end
end
