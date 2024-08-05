# == Schema Information
#
# Table name: ahoy_events
#
#  id         :uuid             not null, primary key
#  visit_id   :uuid
#  user_id    :integer
#  name       :string(255)
#  properties :json
#  time       :datetime
#

module Ahoy
  class Event < ApplicationRecord
    self.table_name = 'ahoy_events'

    belongs_to :visit, class_name: 'Ahoy::Visit', optional: true
    belongs_to :user, optional: true
  end
end
