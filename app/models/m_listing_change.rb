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
#  is_current                :boolean
#  dirty                     :boolean
#  expiry                    :datetime
#

class MListingChange < ActiveRecord::Base
  include PgArrayParser
  self.table_name = :listing_changes_mview
  self.primary_key = :id

  def listing_attributes
    {
      :id => id,
      :species_listing_name => species_listing_name,
      :party_id => party_id,
      :change_type_name => change_type_name,
      :effective_at => effective_at.strftime("%d/%m/%y"),
      :is_current => is_current,
      :specific_note => case I18n.locale
        when :es
          spanish_full_note
        when :fr
          french_full_note
        else
          english_full_note
      end,
      :generic_note => case I18n.locale
        when :es
          generic_spanish_full_note
        when :fr
          generic_french_full_note
        else
          generic_english_full_note
      end,
      :symbol => symbol,
      :parent_symbol => parent_symbol
    }
  end

  def countries_ids
    if respond_to?(:countries_ids_ary)
      parse_pg_array(countries_ids_ary || '').compact
    else
      []
    end
  end

end
