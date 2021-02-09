class Species::QuotaSerializer < ActiveModel::Serializer
  attributes :quota, :year, { :publication_date_formatted => :publication_date },
    :notes, :url, :public_display, :is_current, :subspecies_info,
    :nomenclature_note_en, :nomenclature_note_fr, :nomenclature_note_es,
    :geo_entity,
    :unit

  def geo_entity
    object['geo_entity_en']
  end

  def unit
    object['unit_en']
  end

  def quota
    object['quota_for_display']
  end
end
