class Checklist::HistoryListingChangeSerializer < ActiveModel::Serializer
  attributes :id,
    :species_listing_name, :party_iso_code, :party_full_name,
    :change_type_name, :effective_at_formatted, :is_current,
    :hash_ann_symbol, :hash_full_note,
    :full_note, :short_note, :nomenclature_note
end
