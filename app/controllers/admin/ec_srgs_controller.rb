class Admin::EcSrgsController < Admin::EventsController
  # this needs to be specified, because otherwise defaults to 'event'
  defaults :resource_class => EcSrg,
    :collection_name => 'ec_srgs',
    :instance_name => 'ec_srg'

  protected

  def collection
    @ec_srgs ||= end_of_association_chain.
      order('designation_id, effective_at DESC').includes(:designation).
      page(params[:page]).
      search(params[:query])
  end
end
