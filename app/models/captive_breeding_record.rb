##
# Base class for accessing Captive Breeding Database, NOT the SAPI db.
# Used for periodically synchronising users to the Captive Breeding Database.

class CaptiveBreedingRecord < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :captive_breeding, reading: :captive_breeding }
end
