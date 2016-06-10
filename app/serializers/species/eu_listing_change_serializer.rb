class Species::EuListingChangeSerializer < Species::ListingChangeSerializer
  attributes :event_name, :event_url,
    :change_type, :is_addition, :change_type_class,
    :hash_full_note_en, :hash_display,
    :nomenclature_note_en, :nomenclature_note_fr, :nomenclature_note_es

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

  def change_type_class
    object.change_type_name.downcase
  end
end
