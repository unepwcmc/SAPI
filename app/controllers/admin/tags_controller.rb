class Admin::TagsController < Admin::SimpleCrudController
  defaults :resource_class => PresetTag, :collection_name => 'tags', :instance_name => 'tag'

  authorize_resource :class => false

  protected

  def collection
    @tags ||= end_of_association_chain.page(params[:page]).
      order('UPPER(name) ASC, model ASC').
      search(params[:query])
  end
end
