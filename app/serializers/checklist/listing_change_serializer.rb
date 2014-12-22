class Checklist::ListingChangeSerializer < ActiveModel::Serializer
  attributes :id, :change_type_name, :species_listing_name,
    :party_id, :party_iso_code, :party_full_name, :is_current,
    :hash_ann_symbol, :auto_note, :full_note, :hash_full_note,
    :short_note, :inherited_short_note, :inherited_full_note,
    :countries_ids, :effective_at_formatted, :nomenclature_note
end
