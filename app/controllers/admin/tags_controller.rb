class Admin::TagsController < Admin::SimpleCrudController
  defaults :resource_class => PresetTag, :collection_name => 'tags', :instance_name => 'tag'

  protected

  def collection
    @tags ||= end_of_association_chain.page(params[:page]).
      order('UPPER(name) ASC, model ASC')
  end
end
