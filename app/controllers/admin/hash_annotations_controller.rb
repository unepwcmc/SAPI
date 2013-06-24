class Admin::HashAnnotationsController < Admin::SimpleCrudController
  respond_to :json, :only => [:index, :update]
  defaults :resource_class => Annotation, :collection_name => 'annotations',
    :instance_name => 'annotation'

  protected
  def collection
  	@annotations = load_collection.page(params[:page])
  end

end

