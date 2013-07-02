class Instrument < ActiveRecord::Base
  attr_accessible :designation_id, :name

  belongs_to :designation
end
