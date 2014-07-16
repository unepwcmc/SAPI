module Ahoy
  class Event < ActiveRecord::Base
  	events = Ahoy::Event.all
    self.table_name = 'ahoy_events'

    belongs_to :visit, class_name: 'Ahoy::Visit'
    belongs_to :user
    serialize :properties, JSON
  end
end
