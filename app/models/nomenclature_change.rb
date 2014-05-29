class NomenclatureChange < ActiveRecord::Base
  track_who_does_it
  attr_accessible :created_by_id, :event_id, :updated_by_id,
    :input_attributes, :outputs_attributes
  belongs_to :event
end
