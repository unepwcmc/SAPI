class Admin::EcSrgsController < Admin::EventsController
  # this needs to be specified, because otherwise defaults to 'event'
  defaults resource_class: EcSrg,
    collection_name: 'ec_srgs',
    instance_name: 'ec_srg'

protected

  def collection
    @ec_srgs ||= end_of_association_chain.order(
      'designation_id, effective_at DESC'
    ).includes(:designation).page(
      params[:page]
    ).search(
      params[:query]
    )
  end

private

  def ec_srg_params
    params.require(:ec_srg).permit(
      # attributes were in model `attr_accessible`.
      :is_current, :name, :designation_id, :description, :extended_description,
      :url, :private_url, :multilingual_url, :published_at, :effective_at, :is_current, :end_date,
      :created_by_id, :updated_by_id
    )
  end
end
