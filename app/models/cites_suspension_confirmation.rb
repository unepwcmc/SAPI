# == Schema Information
#
# Table name: cites_suspension_confirmations
#
#  id                               :integer          not null, primary key
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  cites_suspension_id              :integer          not null
#  cites_suspension_notification_id :integer          not null
#
# Foreign Keys
#
#  cites_suspension_confirmations_cites_suspension_id_fk  (cites_suspension_id => trade_restrictions.id)
#  cites_suspension_confirmations_notification_id_fk      (cites_suspension_notification_id => events.id)
#

class CitesSuspensionConfirmation < ApplicationRecord
  # Migrated to controller (Strong Parameters)
  # attr_accessible :cites_suspension_notification_id
  belongs_to :confirmation_notification, class_name: 'CitesSuspensionNotification',
    foreign_key: :cites_suspension_notification_id
  belongs_to :confirmed_suspension, class_name: 'CitesSuspension',
    foreign_key: :cites_suspension_id
end
