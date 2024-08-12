class Admin::EuCouncilRegulationsController < Admin::EventsController
  # this needs to be specified, because otherwise defaults to 'event'
  defaults resource_class: EuCouncilRegulation,
    collection_name: 'eu_council_regulations', instance_name: 'eu_council_regulation'

  protected

  def collection
    @eu_council_regulations ||= end_of_association_chain.
      order('effective_at DESC, name ASC').
      page(params[:page]).
      search(params[:query])
  end

  def list_template
    'admin/eu_regulations_common/list'
  end

  private

  def eu_council_regulation_params
    params.require(:eu_council_regulation).permit(
      # attributes were in model `attr_accessible`.
      :name, :designation_id, :description, :extended_description,
      :url, :private_url, :multilingual_url, :published_at, :effective_at, :is_current, :end_date,
      :created_by_id, :updated_by_id
    )
  end
end
