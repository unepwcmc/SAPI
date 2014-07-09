module Ahoy
  class Visit < ActiveRecord::Base
    self.table_name = 'ahoy_visits'

    has_many :ahoy_events, class_name: 'Ahoy::Event'
    belongs_to :user
  end
end
