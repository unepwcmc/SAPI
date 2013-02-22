# == Schema Information
#
# Table name: trade_restrictions
#
#  id               :integer          not null, primary key
#  is_current       :boolean
#  start_date       :datetime
#  end_date         :datetime
#  geo_entity_id    :integer
#  quota            :integer
#  published_date   :datetime
#  notes            :text
#  suspension_basis :string(255)
#  restriction_type :string(255)
#  unit_id          :integer
#  term_id          :integer
#  source_id        :integer
#  purpose_id       :integer
#  designation_id   :integer
#  taxon_concept_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class TradeRestriction < ActiveRecord::Base
  attr_accessible :end_date, :geo_entity_id, :is_current, :notes, :published_date, :purpose_id, :quota, :restriction_type, :source_id, :start_date, :suspension_basis, :term_id, :unit_id

  belongs_to :taxon_concept
  belongs_to :designation
  belongs_to :unit, :class_name => 'TradeCode'
  belongs_to :term, :class_name => 'TradeCode'
  belongs_to :source, :class_name => 'TradeCode'
  belongs_to :purpose, :class_name => 'TradeCode'
end
