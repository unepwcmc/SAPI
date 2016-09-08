class Admin::TaxonEuSuspensionsController < Admin::SimpleCrudController
  belongs_to :taxon_concept
  defaults :resource_class => EuSuspension,
    :collection_name => 'eu_suspensions', :instance_name => 'eu_suspension'
  before_filter :load_lib_objects
  before_filter :load_search, :only => [:new, :index, :edit]

  layout 'taxon_concepts'

  authorize_resource :class => false

  def update
    update! do |success, failure|
      success.html {
        if "1" == params[:redirect_to_eu_suspension_reg]
          redirect_to admin_eu_suspension_regulation_eu_suspensions_url(
            @eu_suspension.start_event_id)
        else
          redirect_to admin_taxon_concept_eu_suspensions_url(
            params[:taxon_concept_id]),
          :notice => 'Operation successful'
        end
      }
      failure.html {
        load_lib_objects
        load_search
        render 'new'
      }

      success.js { render 'create' }
      failure.js {
        load_lib_objects
        render 'new'
      }
    end
  end

  def create
    create! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_eu_suspensions_url(params[:taxon_concept_id]),
        :notice => 'Operation successful'
      }
      failure.html {
        load_search
        render 'create'
      }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_eu_suspensions_url(@taxon_concept),
        :notice => 'Operation successful'
      }
    end
  end

  protected

  def load_lib_objects
    @terms = Term.order(:code)
    @sources = Source.order(:code)
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
      where(:geo_entity_types => { :name => GeoEntityType::SETS[GeoEntityType::DEFAULT_SET] })
    @eu_regulations = EuSuspensionRegulation.order("effective_at DESC")
    @eu_decision_types = EuDecisionType.suspensions
  end

  def collection
    @eu_suspensions ||= end_of_association_chain.
      joins(:geo_entity).
      order('is_current DESC, start_date DESC,
        geo_entities.name_en ASC').
      page(params[:page])
  end
end
