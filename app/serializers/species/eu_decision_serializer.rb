class Species::EuDecisionSerializer < ActiveModel::Serializer
  attributes :notes, { :start_date_formatted => :start_date },
    :is_current, :subspecies_info, :nomenclature_note_en, :nomenclature_note_fr,
    :nomenclature_note_es,
    :eu_decision_type,
    :geo_entity,
    :start_event,
    :source,
    :term,
    { :original_start_date_formatted => :original_start_date }

  def eu_decision_type
    object['eu_decision_type']
  end

  def geo_entity
    object['geo_entity_en']
  end

  def start_event
    object['start_event']
  end

  def source
    object['source_en']
  end

  def term
    object['term_en']
  end
end
