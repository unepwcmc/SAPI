# == Schema Information
#
# Table name: cites_suspension_confirmations
#
#  id                               :integer          not null, primary key
#  cites_suspension_id              :integer          not null
#  cites_suspension_notification_id :integer          not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#

class CitesSuspensionConfirmation < ActiveRecord::Base
  attr_accessible :cites_suspension_notification_id
  belongs_to :confirmation_notification, :class_name => 'CitesSuspensionNotification',
    :foreign_key => :cites_suspension_notification_id
  belongs_to :confirmed_suspension, :class_name => 'CitesSuspension',
    :foreign_key => :cites_suspension_id
end
