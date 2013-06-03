class CitesSuspensionConfirmation < ActiveRecord::Base
  attr_accessible :cites_suspension_notification_id
  belongs_to :confirmation_notification, :class_name => 'CitesSuspensionNotification', :foreign_key => :cites_suspension_notification_id
end