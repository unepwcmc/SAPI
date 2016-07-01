class Admin::CitesPcsController < Admin::EventsController
  # this needs to be specified, because otherwise defaults to 'event'
  defaults :resource_class => CitesPc,
    :collection_name => 'cites_pcs',
    :instance_name => 'cites_pc'

  protected

  def collection
    @cites_pcs ||= end_of_association_chain.
      order(:designation_id, :name).includes(:designation).
      page(params[:page]).
      search(params[:query])
  end
end
