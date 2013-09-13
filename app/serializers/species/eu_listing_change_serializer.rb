class Species::EuListingChangeSerializer < ActiveModel::Serializer
  attributes :is_current, :species_listing_name, :party_full_name,
   :effective_at_formatted, :short_note_en, :full_note_en,
   :event_name, :event_url, :hash_full_note_en, :hash_display,
   :subspecies_info

  def hash_display
    return "" unless object.hash_ann_parent_symbol.present?
    object.hash_ann_symbol + " " + object.hash_ann_parent_symbol
  end
end
