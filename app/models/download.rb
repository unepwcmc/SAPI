class Download < ActiveRecord::Base
  attr_accessible :format, :doc_type

  COMPLETED = 'completed'
  FAILED    = 'failed'
  WORKING   = 'working'
end
