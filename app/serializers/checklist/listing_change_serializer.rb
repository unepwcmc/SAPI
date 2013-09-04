class Checklist::ListingChangeSerializer < ActiveModel::Serializer
  attributes :id, :change_type_name, :species_listing_name,
    :party_id, :party_iso_code, :party_full_name, :is_current, 
    :hash_ann_symbol, :auto_note, :full_note_en, :hash_full_note_en,
    :short_note_en, :short_note_es, :short_note_fr, 
    :inherited_short_note_en, :inherited_full_note_en,
    :countries_ids, :effective_at_formatted
end
