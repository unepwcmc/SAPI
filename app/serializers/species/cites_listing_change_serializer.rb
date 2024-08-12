class Species::CitesListingChangeSerializer < Species::ListingChangeSerializer
  attributes :change_type, :is_addition, :listed_geo_entities, :excluded_geo_entities,
    :hash_full_note_en, :hash_display,
    :nomenclature_note_en, :nomenclature_note_fr, :nomenclature_note_es

  def include_is_addition?
    return true unless @options[:trimmed]
    @options[:trimmed] == 'false'
  end

  def include_nomenclature_note_fr?
    return true unless @options[:trimmed]
    @options[:trimmed] == 'false'
  end

  def include_nomenclature_note_es?
    return true unless @options[:trimmed]
    @options[:trimmed] == 'false'
  end

  def change_type
    if object.change_type_name == ChangeType::RESERVATION_WITHDRAWAL
      'w'
    elsif object.change_type_name == ChangeType::DELETION
      'x'
    else
      object.change_type_name.downcase[0]
    end
  end

  def is_addition
    object.change_type_name == ChangeType::ADDITION
  end


  def excluded_geo_entities
    if object.party_full_name.blank?
      object.excluded_geo_entities_ids
    end
  end

  def listed_geo_entities
    if object.party_full_name.blank?
      object.listed_geo_entities_ids
    end
  end
end
