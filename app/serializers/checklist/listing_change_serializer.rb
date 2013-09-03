class Checklist::ListingChangeSerializer < ActiveModel::Serializer
  attributes :id, :change_type_name, :species_listing_name,
    :party_id, :is_current, :hash_ann_symbol, :auto_note,
    :short_note_en, :full_note_en, :hash_full_note_en,
    :inherited_short_note_en, :inherited_full_note_en,
    :countries_ids, :effective_at_formatted
end
