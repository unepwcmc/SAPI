module Ahoy
  class Visit < ActiveRecord::Base
  	visits = Ahoy::Visit.all
    self.table_name = 'ahoy_visits'


    has_many :ahoy_events, class_name: 'Ahoy::Event'
    belongs_to :user
  end
end
