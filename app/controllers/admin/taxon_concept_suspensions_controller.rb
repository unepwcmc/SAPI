class Admin::TaxonConceptSuspensionsController < Admin::SimpleCrudController
  defaults :resource_class => Suspension, :collection_name => 'suspensions', :instance_name => 'suspension'
  belongs_to :taxon_concept

  before_filter :load_lib_objects
  layout 'taxon_concepts'

  def update
    update! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_suspensions_url(@taxon_concept),
        :notice => 'Operation successful'
      }
      failure.html {
        load_lib_objects
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
        redirect_to admin_taxon_concept_suspensions_url(@taxon_concept),
        :notice => 'Operation successful'
      }
      failure.html { render 'create' }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_suspensions_url(@taxon_concept),
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
      where(:is_current => true, :geo_entity_types => {:name => 'COUNTRY'})
  end

  def collection
    @suspensions ||= end_of_association_chain.page(params[:page])
  end
end
