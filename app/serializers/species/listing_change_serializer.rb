class Species::ListingChangeSerializer < ActiveModel::Serializer
  attributes :is_current, :species_listing_name, :party_full_name,
   :effective_at_formatted, :short_note_en, :full_note_en, :auto_note,
   :change_type, :is_addition, :is_inclusion, :hash_full_note_en, :hash_display,
   :subspecies_info, :inherited_full_note_en, :inherited_short_note_en

  def change_type
    if object.change_type_name == ChangeType::RESERVATION_WITHDRAWAL
      "w"
    elsif object.change_type_name == ChangeType::DELETION
      "x"
    else
      object.change_type_name.downcase[0]
    end
  end
 
  def is_addition
    object.change_type_name == ChangeType::ADDITION
  end

  def is_inclusion
    object.inclusion_taxon_concept_id
  end

  def hash_display
    return "" unless object.hash_ann_parent_symbol.present?
    object.hash_ann_parent_symbol + object.hash_ann_symbol
  end
end

