class Admin::CitesSuspensionNotificationsController < Admin::EventsController
  #this needs to be specified, because otherwise defaults to 'event'
  defaults :resource_class => CitesSuspensionNotification,
    :collection_name => 'cites_suspension_notifications', :instance_name => 'cites_suspension_notification'

  protected
    def collection
      @cites_suspension_notifications ||= end_of_association_chain.
        order(:designation_id, :name).includes(:designation).page(params[:page])
    end

end
