class Admin::CitesTcsController < Admin::EventsController
  # this needs to be specified, because otherwise defaults to 'event'
  defaults :resource_class => CitesTc,
    :collection_name => 'cites_tcs',
    :instance_name => 'cites_tc'

  protected

  def collection
    @cites_tcs ||= end_of_association_chain.
      order(:designation_id, :name).includes(:designation).
      page(params[:page]).
      search(params[:query])
  end
end
