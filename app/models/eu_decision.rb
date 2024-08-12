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
#  index_eu_decisions_on_document_id  (document_id)
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

require 'digest/sha1'
require 'csv'
class EuDecision < ApplicationRecord
  include Changeable
  extend Mobility
  include TrackWhoDoesIt
  # Migrated to controller (Strong Parameters)
  # attr_accessible :end_date, :end_event_id, :geo_entity_id, :internal_notes,
  #   :is_current, :notes, :start_date, :start_event_id, :eu_decision_type_id,
  #   :taxon_concept_id, :type, :conditions_apply, :term_id, :source_id,
  #   :nomenclature_note_en, :nomenclature_note_es, :nomenclature_note_fr,
  #   :created_by_id, :updated_by_id, :srg_history_id

  belongs_to :taxon_concept
  belongs_to :m_taxon_concept, :foreign_key => :taxon_concept_id, optional: true
  belongs_to :geo_entity
  belongs_to :eu_decision_type, optional: true
  belongs_to :srg_history, optional: true
  belongs_to :source, :class_name => 'TradeCode', optional: true
  belongs_to :term, :class_name => 'TradeCode', optional: true
  belongs_to :start_event, :class_name => 'Event', optional: true
  belongs_to :end_event, :class_name => 'Event', optional: true
  has_many :eu_decision_confirmations,
    :dependent => :destroy

  validate :eu_decision_type_and_or_srg_history

  translates :nomenclature_note

  after_commit :cache_cleanup, on: :destroy

  def year
    start_date ? start_date.strftime('%Y') : ''
  end

  def start_date_formatted
    start_date ? start_date.strftime("%d/%m/%Y") : ""
  end

  def party
    geo_entity.try(:name_en)
  end

  def start_event_name
    start_event.try(:name)
  end

  def decision_type
    if eu_decision_type.tooltip.present?
      "#{eu_decision_type.name} (#{eu_decision_type.tooltip})"
    else
      eu_decision_type.name
    end
  end

  def source_name
    source.try(:name_en)
  end

  def term_name
    term.try(:name_en)
  end

  def eu_decision_type_and_or_srg_history
    return if eu_decision_type_id || srg_history_id
    errors.add(:base, "Eu decision type and SRG history can't be blank at the same time")
  end

  private

  def cache_cleanup
    DownloadsCacheCleanupWorker.perform_async('eu_decisions')
  end
end
