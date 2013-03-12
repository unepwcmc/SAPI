class Admin::TaxonConceptSuspensionsController < Admin::SimpleCrudController
  defaults :resource_class => Suspension, :collection_name => 'suspensions', :instance_name => 'suspension'
  belongs_to :taxon_concept

  before_filter :load_lib_objects

  def create
    create! do |format|
      debugger
    end
  end

  def load_lib_objects
    @current_suspensions = Suspension.where(:is_current => true)
    @units = Unit.order(:code)
    @terms = Term.order(:code)
    @sources = Source.order(:code)
    @purposes = Purpose.order(:code)
    @geo_entities = GeoEntity.order(:name_en).joins(:geo_entity_type).
      where(:is_current => true, :geo_entity_types => {:name => 'COUNTRY'})
  end

  def collection
    @suspensions ||= end_of_association_chain.order('start_date').
      page(params[:page])
  end
end
