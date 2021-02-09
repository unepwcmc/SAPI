class Species::CitesSuspensionSerializer < ActiveModel::Serializer
  attributes :notes, { :start_date_formatted => :start_date },
    :is_current, :subspecies_info, :nomenclature_note_en, :nomenclature_note_fr,
    :nomenclature_note_es,
    :geo_entity,
    :applies_to_import,
    :start_notification

  def geo_entity
    object['geo_entity_en']
  end

  def start_notification
    object['start_notification']
  end
end
