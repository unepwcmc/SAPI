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
#  countries_ids_ary         :string
#  dirty                     :boolean
#  expiry                    :datetime
#

#TODO party_name should actually be renamed to party_iso_code
class MListingChange < ActiveRecord::Base
  include PgArrayParser
  self.table_name = :listing_changes_mview
  self.primary_key = :id

  def effective_at_formatted
    effective_at.strftime("%d/%m/%y")
  end

  def specific_short_note
    case I18n.locale
      when :es
        spanish_short_note
      when :fr
        french_short_note
      else
        english_short_note
    end
  end

  def specific_full_note
    case I18n.locale
      when :es
        spanish_full_note
      when :fr
        french_full_note
      else
        english_full_note
    end
  end

  def generic_note
    case I18n.locale
      when :es
        generic_spanish_full_note
      when :fr
        generic_french_full_note
      else
        generic_english_full_note
    end
  end

  def countries_ids
    if respond_to?(:countries_ids_ary) && countries_ids_ary?
      parse_pg_array(countries_ids_ary || '').compact
    elsif respond_to? :lc_countries_ids_ary
      parse_pg_array(lc_countries_ids_ary || '').compact
    else
      []
    end
  end

  def countries_iso_codes
    CountryDictionary.instance.get_iso_codes_by_ids(countries_ids)
  end

  def countries_full_names
    CountryDictionary.instance.get_names_by_ids(countries_ids)
  end

  def party_full_name
    CountryDictionary.instance.get_name_by_id(party_id)
  end

  def to_timeline_event
    TimelineEvent.new(
      self.as_json(
        :only => [
          :id, :change_type_name, :is_current, :parent_symbol, :party_id,
          :species_listing_name, :symbol, :effective_at
        ],
        :methods => [
          :specific_short_note, :specific_full_note, :generic_note,
          :effective_at_formatted, :countries_ids
        ]
      ).symbolize_keys
    )
  end

end
