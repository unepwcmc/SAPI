class Listing < ActiveRecord::Base
  attr_accessible :depth, :lft, :parent_id, :rgt, :species_listing_id, :taxon_concept_id
end
