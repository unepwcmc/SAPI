# == Schema Information
#
# Table name: trade_restrictions
#
#  id               :integer          not null, primary key
#  is_current       :boolean
#  start_date       :datetime
#  end_date         :datetime
#  geo_entity_id    :integer
#  quota            :float
#  publication_date :datetime
#  notes            :text
#  suspension_basis :string(255)
#  type             :string(255)
#  unit_id          :integer
#  taxon_concept_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  public_display   :boolean          default(TRUE)
#  url              :text
#

class TradeRestriction < ActiveRecord::Base
  attr_accessible :end_date, :geo_entity_id, :is_current,
    :notes, :publication_date, :purpose_ids, :quota, :type,
    :source_ids, :start_date, :suspension_basis, :term_ids,
    :unit_id

  belongs_to :taxon_concept
  belongs_to :m_taxon_concept, :foreign_key => :taxon_concept_id
  belongs_to :unit, :class_name => 'TradeCode'
  has_many :trade_restriction_terms, :dependent => :destroy
  has_many :terms, :through => :trade_restriction_terms
  has_many :trade_restriction_sources, :dependent => :destroy
  has_many :sources, :through => :trade_restriction_sources
  has_many :trade_restriction_purposes, :dependent => :destroy
  has_many :purposes, :through => :trade_restriction_purposes

  belongs_to :geo_entity

  validates :publication_date, :presence => true

  validate :valid_dates
  def valid_dates
    if !(start_date.nil? || end_date.nil?) && (start_date > end_date)
      self.errors.add(:start_date, ' has to be before end date.')
    end
  end

  def publication_date_formatted
    publication_date ? publication_date.strftime('%d/%m/%Y') : ''
  end

  def start_date_formatted
    start_date ? start_date.strftime('%d/%m/%Y') : Time.now.beginning_of_year.strftime("%d/%m/%Y")
  end

  def end_date_formatted
    end_date ? end_date.strftime('%d/%m/%Y') : Time.now.end_of_year.strftime("%d/%m/%Y")
  end
end
