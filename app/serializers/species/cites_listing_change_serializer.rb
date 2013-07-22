class Species::CitesListingChangeSerializer < ActiveModel::Serializer
  attributes :is_current, :species_listing_name, :party_full_name,
   :effective_at_formatted, :short_note_en, :full_note_en, :auto_note,
   :change_type, :is_addition, :hash_ann_symbol, :hash_ann_parent_symbol,
   :hash_full_note_en

  def change_type
    if object.change_type_name == ChangeType::RESERVATION_WITHDRAWAL
      "w"
    else
      object.change_type_name.downcase[0]
    end
  end
 
  def is_addition
    object.change_type_name == ChangeType::ADDITION
  end
end

