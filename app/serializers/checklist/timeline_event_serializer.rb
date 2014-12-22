class Checklist::TimelineEventSerializer < ActiveModel::Serializer
  attributes :id, :change_type_name, :species_listing_name,
  :effective_at_formatted, :party_id, :is_current, :auto_note, :short_note,
  :full_note, :hash_full_note, :hash_ann_symbol, :hash_ann_parent_symbol,
  :inherited_short_note, :inherited_full_note, :nomenclature_note,
  :pos
end
