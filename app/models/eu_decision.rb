class EuDecision < ActiveRecord::Base
  attr_accessible :comments, :conditions, :end_date, :geo_entity_id,
    :is_current, :law_id, :restriction, :restriction_text, :source_id,
    :start_date, :taxon_concept_id, :term_id, :type, :conditions_apply

  belongs_to :taxon_concept
  belongs_to :geo_entity

  belongs_to :source, :class_name => 'TradeCode'
  belongs_to :term, :class_name => 'TradeCode'


  RESTRICTION_TYPES = [
    'b', '+', '-', '-Removed'
  ]

  validates :restriction, { presence: true, inclusion: { :in => RESTRICTION_TYPES } }
  validates :start_date, presence: true
  validates :taxon_concept, presence: true

  def year
    start_date ? start_date.strftime('%Y') : ''
  end
end
