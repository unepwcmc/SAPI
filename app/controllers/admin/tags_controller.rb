class Admin::TagsController < Admin::SimpleCrudController
  defaults :resource_class => ActsAsTaggableOn::Tag, :collection_name => 'tags', :instance_name => 'tag'

  protected

  def collection
    @tags ||= end_of_association_chain.page(params[:page])
  end
end
