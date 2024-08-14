class Species::EuDecisionSerializer < ActiveModel::Serializer
  attributes :notes, { start_date_formatted: :start_date },
    :is_current, :subspecies_info, :nomenclature_note_en, :nomenclature_note_fr,
    :nomenclature_note_es,
    :eu_decision_type,
    :srg_history,
    :geo_entity,
    :start_event,
    :source,
    :term,
    { original_start_date_formatted: :original_start_date },
    :private_url,
    :intersessional_decision_id

  def include_nomenclature_note_fr?
    return true unless @options[:trimmed]

    @options[:trimmed] == 'false'
  end

  def include_nomenclature_note_es?
    return true unless @options[:trimmed]

    @options[:trimmed] == 'false'
  end

  def include_private_url?
    return true unless @options[:trimmed]

    @options[:trimmed] == 'false'
  end

  def include_intersessional_decision_id?
    return true unless @options[:trimmed]

    @options[:trimmed] == 'false'
  end

  def eu_decision_type
    @options[:trimmed] == 'true' ? object['eu_decision_type'].slice('name') : object['eu_decision_type']
  end

  def srg_history
    @options[:trimmed] == 'true' ? object['srg_history'].except('description') : object['srg_history']
  end

  def geo_entity
    object['geo_entity_en']
  end

  def start_event
    @options[:trimmed] == 'true' ? object['start_event'].except('date') : object['start_event']
  end

  def source
    object['source_en']
  end

  def term
    @options[:trimmed] == 'true' ? object['term_en'].slice('name') : object['term_en']
  end

  def private_url
    scope.current_user ? object['private_url'] : nil
  end

  def intersessional_decision_id
    scope.current_user ? object['intersessional_decision_id'] : nil
  end
end
