class ApplicationRecord < ActiveRecord::Base
  include SearchableRelation
  include ProtectedDeletion
  include ComparisonAttributes

  primary_abstract_class
end
