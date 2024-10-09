class Admin::CitesPcsController < Admin::EventsController
  # this needs to be specified, because otherwise defaults to 'event'
  defaults resource_class: CitesPc,
    collection_name: 'cites_pcs',
    instance_name: 'cites_pc'

protected

  def collection
    @cites_pcs ||= end_of_association_chain.order(
      :designation_id, :name
    ).includes(
      :designation
    ).page(
      params[:page]
    ).search(
      params[:query]
    )
  end

private

  def cites_pc_params
    params.require(:cites_pc).permit(
      # attributes were in model `attr_accessible`.
      :is_current, :name, :designation_id, :description, :extended_description,
      :url, :private_url, :multilingual_url, :published_at, :effective_at, :is_current, :end_date,
      :created_by_id, :updated_by_id
    )
  end
end
