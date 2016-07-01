class Admin::CitesCopsController < Admin::EventsController
  # this needs to be specified, because otherwise defaults to 'event'
  defaults :resource_class => CitesCop,
    :collection_name => 'cites_cops', :instance_name => 'cites_cop'

  protected

  def collection
    @cites_cops ||= end_of_association_chain.
      order(:designation_id, :name).includes(:designation).
      page(params[:page]).
      search(params[:query])
  end
end
