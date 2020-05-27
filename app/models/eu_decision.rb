# == Schema Information
#
# Table name: eu_decisions
#
#  id                   :integer          not null, primary key
#  is_current           :boolean          default(TRUE)
#  notes                :text
#  internal_notes       :text
#  taxon_concept_id     :integer
#  geo_entity_id        :integer          not null
#  start_date           :datetime
#  start_event_id       :integer
#  end_date             :datetime
#  end_event_id         :integer
#  type                 :string(255)
#  conditions_apply     :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  eu_decision_type_id  :integer
#  term_id              :integer
#  source_id            :integer
#  created_by_id        :integer
#  updated_by_id        :integer
#  nomenclature_note_en :text
#  nomenclature_note_es :text
#  nomenclature_note_fr :text
#

require 'digest/sha1'
require 'csv'
class EuDecision < ActiveRecord::Base
  track_who_does_it
  attr_accessible :end_date, :end_event_id, :geo_entity_id, :internal_notes,
    :is_current, :notes, :start_date, :start_event_id, :eu_decision_type_id,
    :taxon_concept_id, :type, :conditions_apply, :term_id, :source_id,
    :nomenclature_note_en, :nomenclature_note_es, :nomenclature_note_fr,
    :created_by_id, :updated_by_id, :srg_history_id

  belongs_to :taxon_concept
  belongs_to :m_taxon_concept, :foreign_key => :taxon_concept_id
  belongs_to :geo_entity
  belongs_to :eu_decision_type
  belongs_to :srg_history
  belongs_to :source, :class_name => 'TradeCode'
  belongs_to :term, :class_name => 'TradeCode'
  belongs_to :start_event, :class_name => 'Event'
  belongs_to :end_event, :class_name => 'Event'
  has_many :eu_decision_confirmations,
    :dependent => :destroy

  validates :taxon_concept, presence: true
  validates :geo_entity, presence: true
  validate :eu_decision_type_and_or_srg_history

  translates :nomenclature_note

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
end
