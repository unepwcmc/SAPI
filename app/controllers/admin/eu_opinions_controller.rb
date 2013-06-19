class Admin::EuOpinionsController < Admin::SimpleCrudController
  belongs_to :taxon_concept
  before_filter :load_lib_objects

  layout 'taxon_concepts'

  def update
    update! do |success, failure|
      success.html {
        redirect_to admin_taxon_concept_eu_opinions_url(params[:taxon_concept_id]),
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
        redirect_to admin_taxon_concept_eu_opinions_url(params[:taxon_concept_id]),
        :notice => 'Operation successful'
      }
      failure.html { render 'create' }
    end
  end

  protected

  def load_lib_objects
    @terms = Term.order(:code)
    @sources = Source.order(:code)
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
      where(:is_current => true, :geo_entity_types => {:name => 'COUNTRY'})
    @laws = Event.joins(:designation).where('designations.name' => 'EU')
  end

  def collection
    @eu_opinions ||= end_of_association_chain.order('start_date').
      page(params[:page])
  end
end
