class Admin::EuImplementingRegulationsController < Admin::EventsController
  # this needs to be specified, because otherwise defaults to 'event'
  defaults :resource_class => EuImplementingRegulation,
    :collection_name => 'eu_implementing_regulations', :instance_name => 'eu_implementing_regulation'

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
end
