# == Schema Information
#
# Table name: eu_decisions
#
#  id                  :integer          not null, primary key
#  is_current          :boolean          default(TRUE)
#  notes               :text
#  internal_notes      :text
#  taxon_concept_id    :integer
#  geo_entity_id       :integer
#  start_date          :datetime
#  start_event_id      :integer
#  end_date            :datetime
#  end_event_id        :integer
#  type                :string(255)
#  conditions_apply    :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  eu_decision_type_id :integer
#  term_id             :integer
#  source_id           :integer
#

class EuDecision < ActiveRecord::Base
  attr_accessible :end_date, :end_event_id, :geo_entity_id, :internal_notes,
    :is_current, :notes, :start_date, :start_event_id, :eu_decision_type_id,
    :taxon_concept_id, :type, :conditions_apply, :term_id, :source_id

  belongs_to :taxon_concept
  belongs_to :geo_entity
  belongs_to :eu_decision_type
  belongs_to :source, :class_name => 'TradeCode'
  belongs_to :term, :class_name => 'TradeCode'
  belongs_to :start_event, :class_name => 'Event'
  has_many :eu_decision_confirmations

  validates :start_date, presence: true
  validates :taxon_concept, presence: true
  validates :eu_decision_type, presence: true

  def year
    start_date ? start_date.strftime('%Y') : ''
  end

  def start_date_formatted
    start_date ? start_date.strftime("%d/%m/%Y") : ""
  end
end
