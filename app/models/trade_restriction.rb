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
#  import_row_id    :integer
#

require 'digest/sha1'
require 'csv'
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

  def self.export filters
    return false if !self.any?
    path = "public/downloads/cites_#{self.to_s.downcase}s/"
    latest = self.order("updated_at DESC").
      limit(1).first.updated_at.strftime("%d%m%Y")
    public_file_name = "#{self.to_s.downcase}s_#{latest}.csv"
    file_name = Digest::SHA1.hexdigest(
      filters.merge(:latest_date => latest).
      to_hash.
      symbolize_keys!.sort
      .to_s
    )+"_cites_#{self.to_s.downcase}s.csv"
    if !File.file?(path+file_name)
      self.to_csv(path+file_name, filters)
    end
    [ path+file_name,
      { :filename => public_file_name, :type => 'text/csv' } ]
  end

  def self.to_csv file_path, filters
    taxonomy_columns = [
      :kingdom_name, :phylum_name,
      :class_name, :order_name,
      :family_name, :genus_name,
      :species_name, :subspecies_name,
      :full_name, :rank_name
    ]
    limit = 1000
    offset = 0
    CSV.open(file_path, 'wb') do |csv|
      csv << taxonomy_columns + ['Remarks'] + self::CSV_COLUMNS
      ids = []
      until (objs = self.includes([:m_taxon_concept, :geo_entity, :unit]).
             filter_is_current(filters["set"]).
             filter_geo_entities(filters).
             filter_years(filters).
             where(:public_display => true).
             order([:start_date, :id]).limit(limit).
             offset(offset)).empty? do
        objs.each do |q|
          row = []
          row += self.fill_taxon_columns(q, taxonomy_columns)
          self::CSV_COLUMNS.each do |c|
            row << q.send(c)
          end
          csv << row
          offset += limit
        end
             end
      end
    end

    def self.fill_taxon_columns trade_restriction, taxonomy_columns
      columns = []
      taxon = trade_restriction.m_taxon_concept
      taxonomy_columns.each do |c|
        columns << taxon.send(c)
      end
      if taxon.name_status == 'A'
        columns << '' #no remarks
      else
        columns << "#{trade_restriction.type} issued for #{taxon.name_status == 'S' ? 'synonym' : 'hybrid' } #{trade_restriction.taxon_concept.legacy_id} - #{trade_restriction.taxon_concept.legacy_type}"
      end
      columns
    end

    def self.filter_is_current set
      if set == "current"
        return where(:is_current => true)
      end
      scoped
    end

    def self.filter_geo_entities filters
      if filters.has_key?("geo_entities_ids")
        return where(:geo_entity_id => filters["geo_entities_ids"])
      end
      scoped
    end

    def self.filter_years filters
      if filters.has_key?("years")
        return where('EXTRACT(YEAR FROM trade_restrictions.start_date) IN (?)',
                     filters["years"])
      end
      scoped
    end
  end
