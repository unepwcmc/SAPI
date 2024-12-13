class CaptiveBreedingRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :captive_breeding, reading: :captive_breeding }
end
