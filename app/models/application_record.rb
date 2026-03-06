class ApplicationRecord < ActiveRecord::Base
  include SearchableRelation
  include ProtectedDeletion
  include ComparisonAttributes
  include CascadeDeletable

  primary_abstract_class
end
