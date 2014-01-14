class MEuListingChange < ActiveRecord::Base
  self.table_name = :eu_listing_changes_mview
  self.primary_key = :id
  include MListingChange
end