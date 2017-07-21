class Admin::HashAnnotationsController < Admin::SimpleCrudController
  authorize_resource class: false
  respond_to :json, :only => [:index, :update]
  defaults :resource_class => Annotation, :collection_name => 'annotations',
    :instance_name => 'annotation'

  protected

  def collection
    @annotations = load_collection.page(params[:page]).
      search(params[:query])
  end

end
