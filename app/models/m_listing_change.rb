# == Schema Information
#
# Table name: listing_changes_mview
#
#  id                        :integer          primary key
#  taxon_concept_id          :integer
#  effective_at              :datetime
#  species_listing_id        :integer
#  species_listing_name      :string(255)
#  change_type_id            :integer
#  change_type_name          :string(255)
#  party_id                  :integer
#  party_name                :string(255)
#  symbol                    :string(255)
#  parent_symbol             :string(255)
#  generic_english_full_note :text
#  generic_spanish_full_note :text
#  generic_french_full_note  :text
#  english_full_note         :text
#  spanish_full_note         :text
#  french_full_note          :text
#  english_short_note        :text
#  spanish_short_note        :text
#  french_short_note         :text
#  dirty                     :boolean
#  expiry                    :datetime
#

class MListingChange < ActiveRecord::Base
  self.table_name = :listing_changes_mview
  self.primary_key = :id
end
