# == Schema Information
#
# Table name: eu_decisions
#
#  id                   :integer          not null, primary key
#  conditions_apply     :boolean
#  end_date             :datetime
#  internal_notes       :text
#  is_current           :boolean          default(TRUE)
#  nomenclature_note_en :text
#  nomenclature_note_es :text
#  nomenclature_note_fr :text
#  notes                :text
#  start_date           :datetime
#  type                 :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  created_by_id        :integer
#  document_id          :integer
#  end_event_id         :integer
#  eu_decision_type_id  :integer
#  geo_entity_id        :integer          not null
#  source_id            :integer
#  srg_history_id       :integer
#  start_event_id       :integer
#  taxon_concept_id     :integer
#  term_id              :integer
#  updated_by_id        :integer
#
# Indexes
#
#  index_eu_decisions_on_created_by_id        (created_by_id)
#  index_eu_decisions_on_document_id          (document_id)
#  index_eu_decisions_on_end_event_id         (end_event_id)
#  index_eu_decisions_on_eu_decision_type_id  (eu_decision_type_id)
#  index_eu_decisions_on_geo_entity_id        (geo_entity_id)
#  index_eu_decisions_on_source_id            (source_id)
#  index_eu_decisions_on_srg_history_id       (srg_history_id)
#  index_eu_decisions_on_start_event_id       (start_event_id)
#  index_eu_decisions_on_taxon_concept_id     (taxon_concept_id)
#  index_eu_decisions_on_term_id              (term_id)
#  index_eu_decisions_on_updated_by_id        (updated_by_id)
#
# Foreign Keys
#
#  eu_decisions_created_by_id_fk        (created_by_id => users.id)
#  eu_decisions_end_event_id_fk         (end_event_id => events.id)
#  eu_decisions_eu_decision_type_id_fk  (eu_decision_type_id => eu_decision_types.id)
#  eu_decisions_geo_entity_id_fk        (geo_entity_id => geo_entities.id)
#  eu_decisions_source_id_fk            (source_id => trade_codes.id)
#  eu_decisions_srg_history_id_fk       (srg_history_id => srg_histories.id)
#  eu_decisions_start_event_id_fk       (start_event_id => events.id)
#  eu_decisions_taxon_concept_id_fk     (taxon_concept_id => taxon_concepts.id)
#  eu_decisions_term_id_fk              (term_id => trade_codes.id)
#  eu_decisions_updated_by_id_fk        (updated_by_id => users.id)
#

class EuSuspension < EuDecision
  def self.search(query)
    self.ilike_search(
      query, [ TaxonConcept.arel_table['full_name'] ]
    )
  end

  def start_date
    start_event && start_event.effective_at
  end

  def end_date
    end_event && end_event.effective_at
  end

  def end_date_formatted
    end_date ? end_date.strftime('%d/%m/%Y') : ''
  end

  def is_current
    return false if !start_event

    start_event.effective_at <= Date.today && start_event.is_current &&
      (!end_event || end_event.effective_at > Date.today)
  end
end
