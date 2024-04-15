class Admin::EuRegulationsController < Admin::EventsController
  # this needs to be specified, because otherwise defaults to 'event'
  defaults :resource_class => EuRegulation,
    :collection_name => 'eu_regulations', :instance_name => 'eu_regulation'

  def activate
    @eu_regulation = EuRegulation.find(params[:id])
    @eu_regulation.activate!
    render 'create'
  end

  def deactivate
    @eu_regulation = EuRegulation.find(params[:id])
    @eu_regulation.deactivate!
    render 'create'
  end

  protected

  def collection
    @eu_regulations ||= end_of_association_chain.
      order('effective_at DESC, name ASC').
      page(params[:page]).
      search(params[:query])
  end

  def load_associations
    @eu_regulations_for_dropdown = EuRegulation.
      order('effective_at DESC, name ASC')
  end

  private

  def eu_regulation_params
    params.require(:eu_regulation).permit(
      # attributes were in model `attr_accessible`.
      :listing_changes_event_id, :name, :designation_id, :description, :extended_description,
      :url, :private_url, :multilingual_url, :published_at, :effective_at, :is_current, :end_date,
      :created_by_id, :updated_by_id
    )
  end
end
