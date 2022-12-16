class Species::CitesSuspensionSerializer < ActiveModel::Serializer
  attributes :notes, { :start_date_formatted => :start_date },
    :is_current, :subspecies_info, :nomenclature_note_en, :nomenclature_note_fr,
    :nomenclature_note_es,
    :geo_entity,
    :applies_to_import,
    :start_notification,
    :source_ids

  def geo_entity
    @options[:trimmed] == 'true' ? object['geo_entity_en'].slice('iso_code2') : object['geo_entity_en']
  end

  def start_notification
    @options[:trimmed] == 'true' ? object['start_notification'].except('date') : object['start_notification']
  end

  def include_nomenclature_note_fr?
    return true unless @options[:trimmed]
    @options[:trimmed] == 'false'
  end

  def include_nomenclature_note_es?
    return true unless @options[:trimmed]
    @options[:trimmed] == 'false'
  end

end
