class Admin::CitesPlantAnnotationsController < Admin::SimpleCrudController
  respond_to :json, :only => [:index, :update]
  defaults :resource_class => Annotation, :collection_name => 'annotations',
    :instance_name => 'annotation'

  protected
    def collection
      @annotations ||= end_of_association_chain.
        for_cites_plants.page(params[:page])
    end

    def load_associations
      @cites_cops = CitesCop.order(:effective_at)
    end

end

