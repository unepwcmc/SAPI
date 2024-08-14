class Admin::EuImplementingRegulationsController < Admin::EventsController
  # this needs to be specified, because otherwise defaults to 'event'
  defaults resource_class: EuImplementingRegulation,
    collection_name: 'eu_implementing_regulations', instance_name: 'eu_implementing_regulation'

protected

  def collection
    @eu_implementing_regulations ||= end_of_association_chain.
      order('effective_at DESC, name ASC').
      page(params[:page]).
      search(params[:query])
  end

  def list_template
    'admin/eu_regulations_common/list'
  end

private

  def eu_implementing_regulation_params
    params.require(:eu_implementing_regulation).permit(
      # attributes were in model `attr_accessible`.
      :name, :designation_id, :description, :extended_description,
      :url, :private_url, :multilingual_url, :published_at, :effective_at, :is_current, :end_date,
      :created_by_id, :updated_by_id
    )
  end
end
