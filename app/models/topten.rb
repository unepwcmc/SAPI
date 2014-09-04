class Topten < ActiveRecord::Base
  attr_accessible :species

  belongs_to :ahoy_event  
end
