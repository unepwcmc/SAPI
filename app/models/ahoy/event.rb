# == Schema Information
#
# Table name: ahoy_events
#
#  id         :uuid             not null, primary key
#  name       :string(255)
#  properties :jsonb
#  time       :datetime
#  user_id    :integer
#  visit_id   :uuid
#
# Indexes
#
#  index_ahoy_events_on_name_and_time  (name,time)
#  index_ahoy_events_on_time           (time)
#  index_ahoy_events_on_user_id        (user_id)
#  index_ahoy_events_on_visit_id       (visit_id)
#
# Foreign Keys
#
#  ahoy_events_user_id_fk  (user_id => users.id)
#

module Ahoy
  class Event < ApplicationRecord
    self.table_name = 'ahoy_events'

    belongs_to :visit, class_name: 'Ahoy::Visit', optional: true
    belongs_to :user, optional: true
  end
end
