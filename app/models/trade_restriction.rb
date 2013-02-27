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
#  publication_date :datetime
#  notes            :text
#  suspension_basis :string(255)
#  type             :string(255)
#  unit_id          :integer
#  term_id          :integer
#  source_id        :integer
#  purpose_id       :integer
#  taxon_concept_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class TradeRestriction < ActiveRecord::Base
  attr_accessible :end_date, :geo_entity_id, :is_current,
    :notes, :published_date, :purpose_id, :quota, :type,
    :source_id, :start_date, :suspension_basis, :term_id,
    :unit_id

  belongs_to :taxon_concept
  belongs_to :unit, :class_name => 'TradeCode'
  belongs_to :term, :class_name => 'TradeCode'
  belongs_to :source, :class_name => 'TradeCode'
  belongs_to :purpose, :class_name => 'TradeCode'

  def publication_date_formatted
    publication_date ? publication_date.strftime('%d/%m/%Y') : ''
  end

  def start_date_formatted
    start_date ? start_date.strftime('%d/%m/%Y') : ''
  end

  def end_date_formatted
    end_date ? end_date.strftime('%d/%m/%Y') : ''
  end
end
