class CitesSuspensionNotificationObserver < ActiveRecord::Observer

  def before_validation(cites_suspension_notification)
    cites = Designation.find_by_name('CITES')
    cites_suspension_notification.designation_id = cites && cites.id
  end

end
