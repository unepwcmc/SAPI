class Species::CitesListingChangeSerializer < Species::ListingChangeSerializer
  attributes :change_type, :is_addition, :hash_full_note_en, :hash_display

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
end
