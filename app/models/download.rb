class Download < ActiveRecord::Base
  attr_accessible :format, :doc_type

  validates :format, :presence => true, :inclusion => { :in => %w(pdf csv json) }
  validates :doc_type, :presence => true, :inclusion => { :in => %w(history index) }


  COMPLETED = 'completed'
  FAILED    = 'failed'
  WORKING   = 'working'
end
