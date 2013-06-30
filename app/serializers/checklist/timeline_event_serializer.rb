class Checklist::TimelineEventSerializer < ActiveModel::Serializer
  attributes :id, :change_type_name, :species_listing_name,
  :effective_at_formatted, :party_id, :is_current, :auto_note, :short_note_en,
  :full_note_en, :hash_full_note_en, :hash_ann_symbol, :hash_ann_parent_symbol,
  :pos
end
