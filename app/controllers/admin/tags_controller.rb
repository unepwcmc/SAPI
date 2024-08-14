class Admin::TagsController < Admin::SimpleCrudController
  defaults resource_class: PresetTag, collection_name: 'tags', instance_name: 'tag'

  authorize_resource class: false

protected

  def collection
    @tags ||= end_of_association_chain.page(params[:page]).
      order(Arel.sql('UPPER(name) ASC'), :model).
      search(params[:query])
  end

private

  def tag_params
    params.require(:tag).permit(
      # attributes were in model `attr_accessible`.
      :model, :name
    )
  end
end
