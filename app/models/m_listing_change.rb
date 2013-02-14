# == Schema Information
#
# Table name: listing_changes_mview
#
#  id                     :integer          primary key
#  taxon_concept_id       :integer
#  effective_at           :datetime
#  species_listing_id     :integer
#  species_listing_name   :string(255)
#  change_type_id         :integer
#  change_type_name       :string(255)
#  party_id               :integer
#  party_name             :string(255)
#  ann_symbol             :string(255)
#  full_note_en           :text
#  full_note_es           :text
#  full_note_fr           :text
#  short_note_en          :text
#  short_note_es          :text
#  short_note_fr          :text
#  display_in_index       :boolean
#  display_in_footnote    :boolean
#  hash_ann_symbol        :string(255)
#  hash_ann_parent_symbol :string(255)
#  hash_full_note_en      :text
#  hash_full_note_es      :text
#  hash_full_note_fr      :text
#  is_current             :boolean
#  countries_ids_ary      :string
#  dirty                  :boolean
#  expiry                 :datetime
#

#TODO party_name should actually be renamed to party_iso_code
class MListingChange < ActiveRecord::Base
  include PgArrayParser
  self.table_name = :listing_changes_mview
  self.primary_key = :id

  def effective_at_formatted
    effective_at.strftime("%d/%m/%y")
  end

  def full_hash_ann_symbol
    "#{hash_ann_parent_symbol}#{hash_ann_symbol}"
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
          :id, :change_type_name, :species_listing_name, :party_id,
          :is_current, :hash_ann_symbol, :hash_ann_parent_symbol,
          :effective_at, :short_note_en, :full_note_en, :hash_full_note_en
        ],
        :methods => [:countries_ids]
      ).symbolize_keys
    )
  end

end
