class MCmsListingChange < ActiveRecord::Base
  self.table_name = :cms_listing_changes_mview
  self.primary_key = :id
  include MListingChange
end