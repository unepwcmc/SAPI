class Admin::CitesExtraordinaryMeetingsController < Admin::EventsController
  # this needs to be specified, because otherwise defaults to 'event'
  defaults :resource_class => CitesExtraordinaryMeeting,
    :collection_name => 'cites_extraordinary_meetings',
    :instance_name => 'cites_extraordinary_meeting'

  protected

  def collection
    @cites_extraordinary_meetings ||= end_of_association_chain.
      order(:designation_id, :name).includes(:designation).
      page(params[:page]).
      search(params[:query])
  end
end
