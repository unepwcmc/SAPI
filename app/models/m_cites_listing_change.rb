class MCitesListingChange < ActiveRecord::Base
  self.table_name = :cites_listing_changes_mview
  self.primary_key = :id
  include MListingChange
end