class Admin::CitesSuspensionNotificationsController < Admin::EventsController
  # this needs to be specified, because otherwise defaults to 'event'
  defaults resource_class: CitesSuspensionNotification,
    collection_name: 'cites_suspension_notifications', instance_name: 'cites_suspension_notification'

  protected

  def collection
    @cites_suspension_notifications ||= end_of_association_chain.
      order('designation_id ASC, events.effective_at DESC, name ASC').
      includes(:designation).
      page(params[:page]).
      search(params[:query])
  end

  private

  def cites_suspension_notification_params
    params.require(:cites_suspension_notification).permit(
      # attributes were in model `attr_accessible`.
      :subtype, :new_subtype, :end_date, :name, :designation_id, :description, :extended_description,
      :url, :private_url, :multilingual_url, :published_at, :effective_at, :is_current, :end_date,
      :created_by_id, :updated_by_id
    )
  end
end
