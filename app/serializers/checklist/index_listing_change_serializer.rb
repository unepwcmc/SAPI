class Checklist::IndexListingChangeSerializer < ActiveModel::Serializer
  attributes :id,
    :species_listing_name, :party_iso_code, :party_full_name,
    :change_type_name, :effective_at_formatted, :is_current,
    :hash_ann_symbol, :hash_full_note_en, :auto_note,
    :full_note_en, :short_note_en, :short_note_es, :short_note_fr
end
