class ApplicationRecord < ActiveRecord::Base
  include ProtectedDeletion
  include ComparisonAttributes

  self.abstract_class = true
end
