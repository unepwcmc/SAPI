class CaptivityProcess < ActiveRecord::Base
  track_who_does_it
  belongs_to :taxon_concept
  belongs_to :geo_entity

  validates :taxon_concept, presence: true
  validates :geo_entity, presence: true
end
