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
    #should have been working with serialize :properties, JSON
    #like it works for other objects.
    #Won't probably work in this case because, in the database,
    #this field is of json type while it should have probably been text/string type.
    #Should be safe to comment this as json type is supported in Rails 4
    # serialize :properties, JSON
  end
end
