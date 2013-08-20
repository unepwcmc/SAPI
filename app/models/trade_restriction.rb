# == Schema Information
#
# Table name: trade_restrictions
#
#  id                          :integer          not null, primary key
#  is_current                  :boolean          default(TRUE)
#  start_date                  :datetime
#  end_date                    :datetime
#  geo_entity_id               :integer
#  quota                       :float
#  publication_date            :datetime
#  notes                       :text
#  type                        :string(255)
#  unit_id                     :integer
#  taxon_concept_id            :integer
#  public_display              :boolean          default(TRUE)
#  url                         :text
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  start_notification_id       :integer
#  end_notification_id         :integer
#  excluded_taxon_concepts_ids :string
#

require 'digest/sha1'
require 'csv'
class TradeRestriction < ActiveRecord::Base
  attr_accessible :end_date, :geo_entity_id, :is_current,
    :notes, :publication_date, :purpose_ids, :quota, :type,
    :source_ids, :start_date, :term_ids, :unit_id

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

  def year
    start_date ? start_date.strftime('%Y') : ''
  end

  def party
    geo_entity_id ? geo_entity.name_en : ''
  end

  def unit_name
    unit_id ? unit.name_en : ''
  end

  def self.export filters
    return false unless export_query(filters).any?
    path = "public/downloads/#{self.to_s.tableize}/"
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
    [
      path + file_name,
      { :filename => public_file_name, :type => 'text/csv' }
    ]
  end

  def self.export_query filters
    self.includes([:m_taxon_concept, :geo_entity, :unit]).
      filter_is_current(filters["set"]).
      filter_geo_entities(filters).
      filter_years(filters).
      filter_taxon_concepts(filters).
      where(:public_display => true).
      order([:start_date, :"trade_restrictions.id"])
  end

  #Gets the display text for each CSV_COLUMNS
  def self.csv_columns_headers
    self::CSV_COLUMNS.map do |b|
      Array(b).first 
    end.flatten
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
      csv << taxonomy_columns + ['Remarks'] + self.csv_columns_headers
      ids = []
      until (objs = export_query(filters).limit(limit).
             offset(offset)).empty? do
        objs.each do |q|
          row = []
          row += self.fill_taxon_columns(q, taxonomy_columns)
          self::CSV_COLUMNS.each do |c|
            if c.is_a?(Array)
              row << q.send(c[1])
            else
              row << q.send(c)
            end
          end
          csv << row
        end
        offset += limit
       end
      end
  end

  def self.fill_taxon_columns trade_restriction, taxonomy_columns
    columns = []
    taxon = trade_restriction.m_taxon_concept
    return [""]*(taxonomy_columns.size+1) unless taxon #return array with empty strings
    taxonomy_columns.each do |c|
      columns << taxon.send(c)
    end
    if taxon.name_status == 'A'
      columns << '' #no remarks
    else
      columns << "Issued for #{taxon.name_status == 'S' ? 'synonym' : 'hybrid' } #{trade_restriction.taxon_concept.full_name}"
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
      geo_entities_ids = GeoEntity.nodes_and_descendants(
        filters["geo_entities_ids"]
      ).map(&:id)
      return where(:geo_entity_id => geo_entities_ids)
    end
    scoped
  end

  def self.filter_taxon_concepts filters
    if filters.has_key?("taxon_concepts_ids")
      conds_str = <<-SQL
        ARRAY[
          taxon_concepts_mview.id, taxon_concepts_mview.family_id, 
          taxon_concepts_mview.order_id, taxon_concepts_mview.class_id, 
          taxon_concepts_mview.phylum_id, taxon_concepts_mview.kingdom_id
        ] && ARRAY[?]
        OR taxon_concept_id IS NULL
      SQL
      return where(conds_str, filters["taxon_concepts_ids"].map(&:to_i))
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
