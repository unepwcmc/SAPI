class Admin::CitesAcsController < Admin::EventsController
  # this needs to be specified, because otherwise defaults to 'event'
  defaults :resource_class => CitesAc,
    :collection_name => 'cites_acs',
    :instance_name => 'cites_ac'

  protected

  def collection
    @cites_acs ||= end_of_association_chain.
      order(:designation_id, :name).includes(:designation).
      page(params[:page]).
      search(params[:query])
  end
end
