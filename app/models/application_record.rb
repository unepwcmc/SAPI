class ApplicationRecord < ActiveRecord::Base
  include SearchableRelation
  include ProtectedDeletion
  include ComparisonAttributes

  self.abstract_class = true
end
