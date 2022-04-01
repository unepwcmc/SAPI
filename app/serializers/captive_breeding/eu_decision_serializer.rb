class CaptiveBreeding::EuDecisionSerializer < ActiveModel::Serializer
  attributes :taxon_concept, :notes, { :start_date_formatted => :start_date },
    :is_current, :nomenclature_note_en, :nomenclature_note_fr,
    :nomenclature_note_es,
    :eu_decision_type,
    :srg_history,
    :geo_entity,
    :start_event,
    :source,
    :term,
    { :original_start_date_formatted => :original_start_date },
    :private_url

  def taxon_concept
    object['taxon_concept']
  end

  def eu_decision_type
    object['eu_decision_type']
  end

  def srg_history
    object['srg_history']
  end

  def geo_entity
    { 'id'=> object['geo_entity_id'] }.merge(object['geo_entity_en'])
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

  def private_url
    scope.current_user ? object['private_url'] : nil
  end
end
