# == Schema Information
#
# Table name: trade_restrictions
#
#  id                          :integer          not null, primary key
#  applies_to_import           :boolean          default(FALSE), not null
#  end_date                    :datetime
#  excluded_taxon_concepts_ids :integer          is an Array
#  internal_notes              :text
#  is_current                  :boolean          default(TRUE)
#  nomenclature_note_en        :text
#  nomenclature_note_es        :text
#  nomenclature_note_fr        :text
#  notes                       :text
#  public_display              :boolean          default(TRUE)
#  publication_date            :datetime
#  quota                       :float
#  start_date                  :datetime
#  type                        :string(255)
#  url                         :text
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  created_by_id               :integer
#  end_notification_id         :integer
#  geo_entity_id               :integer
#  original_id                 :integer
#  start_notification_id       :integer
#  taxon_concept_id            :integer
#  unit_id                     :integer
#  updated_by_id               :integer
#
# Indexes
#
#  idx_on_is_current_type_taxon_concept_id_a115d056cb  (is_current,type,taxon_concept_id)
#  index_trade_restrictions_on_created_by_id           (created_by_id)
#  index_trade_restrictions_on_end_notification_id     (end_notification_id)
#  index_trade_restrictions_on_geo_entity_id           (geo_entity_id)
#  index_trade_restrictions_on_start_notification_id   (start_notification_id)
#  index_trade_restrictions_on_taxon_concept_id        (taxon_concept_id)
#  index_trade_restrictions_on_unit_id                 (unit_id)
#  index_trade_restrictions_on_updated_by_id           (updated_by_id)
#  trade_restrictions_extract_year_from_start_date     (date_part('year'::text, start_date)) WHERE ((type)::text = 'Quota'::text)
#
# Foreign Keys
#
#  trade_restrictions_created_by_id_fk          (created_by_id => users.id)
#  trade_restrictions_end_notification_id_fk    (end_notification_id => events.id)
#  trade_restrictions_geo_entity_id_fk          (geo_entity_id => geo_entities.id)
#  trade_restrictions_start_notification_id_fk  (start_notification_id => events.id)
#  trade_restrictions_taxon_concept_id_fk       (taxon_concept_id => taxon_concepts.id)
#  trade_restrictions_unit_id_fk                (unit_id => trade_codes.id)
#  trade_restrictions_updated_by_id_fk          (updated_by_id => users.id)
#

require 'digest/sha1'
require 'csv'

class TradeRestriction < ApplicationRecord
  extend Mobility
  include TrackWhoDoesIt
  # Migrated to controller (Strong Parameters)
  # attr_accessible :end_date, :geo_entity_id, :is_current,
  #   :notes, :publication_date, :purpose_ids, :quota, :type,
  #   :source_ids, :start_date, :term_ids, :unit_id, :internal_notes,
  #   :nomenclature_note_en, :nomenclature_note_es, :nomenclature_note_fr,
  #   :created_by_id, :updated_by_id, :url,
  #   :taxon_concept_id

  belongs_to :taxon_concept, optional: true
  belongs_to :m_taxon_concept, foreign_key: :taxon_concept_id, optional: true
  belongs_to :unit, class_name: 'TradeCode', optional: true
  has_many :trade_restriction_terms, dependent: :destroy
  has_many :terms, through: :trade_restriction_terms
  has_many :trade_restriction_sources, dependent: :destroy
  has_many :sources, through: :trade_restriction_sources
  has_many :trade_restriction_purposes, dependent: :destroy
  has_many :purposes, through: :trade_restriction_purposes

  belongs_to :geo_entity, optional: true

  validates :publication_date, presence: true
  validate :valid_dates

  translates :nomenclature_note

  before_destroy :touch_descendants, unless: -> { taxon_concept.nil? }
  before_destroy :touch_taxa_with_applicable_distribution, if: -> { taxon_concept.nil? }
  after_save :touch_descendants, unless: -> { taxon_concept.nil? }
  after_save :touch_taxa_with_applicable_distribution, if: -> { taxon_concept.nil? }

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

  def self.search(query)
    return all if query.blank?

    self.ilike_search(
      query, [
        GeoEntity.arel_table['name_en'],
        GeoEntity.arel_table['iso_code2'],
        TaxonConcept.arel_table['full_name'],
        Event.arel_table['subtype']
      ]
    ).or(
      where(
        'trade_restrictions.start_date::text LIKE :query OR trade_restrictions.end_date::text LIKE :query',
        query: "%#{sanitize_sql_like(query)}%"
      )
    ).joins(
      [ :start_notification ]
    ).left_joins(
      [
        :taxon_concept,
        :geo_entity
      ]
    )
  end

  def self.export(filters)
    return false unless export_query(filters).any?

    path = "public/downloads/#{self.to_s.tableize}/"
    latest = self.order('updated_at DESC').
      limit(1).first.updated_at.strftime('%d%m%Y-%H%M%S')
    public_file_name = "#{self.to_s.downcase}s_#{latest}_#{filters[:csv_separator]}_separated.csv"
    file_name = Digest::SHA1.hexdigest(
      filters.merge(latest_date: latest).
      to_hash.
      symbolize_keys!.sort.
      to_s
    ) + "_cites_#{self.to_s.downcase}s.csv"
    if !File.file?(path + file_name)
      self.to_csv(path + file_name, filters)
    end
    [
      path + file_name,
      { filename: public_file_name, type: 'text/csv' }
    ]
  end

  def self.export_query(filters)
    self.joins(
      :geo_entity
    ).left_joins(
      [ :taxon_concept, :m_taxon_concept ]
    ).filter_is_current(
      filters['set']
    ).filter_geo_entities(
      filters
    ).filter_years(
      filters
    ).filter_taxon_concepts(
      filters
    ).where(
      public_display: true
    ).order(
      'taxon_concepts.name_status': :asc,
      'taxon_concepts_mview.taxonomic_position': :asc,
      start_date: :desc,
      'geo_entities.name_en': :asc,
      notes: :asc
    )
  end

  # Gets the display text for each CSV_COLUMNS
  def self.csv_columns_headers
    self::CSV_COLUMNS.map do |b|
      Array(b).first
    end.flatten
  end

  def self.to_csv(file_path, filters)
    limit = 1000
    offset = 0
    csv_separator_char =
      case filters[:csv_separator]
      when :semicolon then ';'
      else ','
      end
    CSV.open(file_path, 'wb', col_sep: csv_separator_char) do |csv|
      csv << (
        Species::RestrictionsExport::TAXONOMY_COLUMN_NAMES +
        [ 'Remarks' ] + self.csv_columns_headers
      )

      until (
        objs = export_query(filters).limit(limit).offset(offset)
      ).empty?
        objs.each do |q|
          row = []
          row += Species::RestrictionsExport.fill_taxon_columns(q)

          self::CSV_COLUMNS.each do |c|
            if c.is_a?(Array)
              row << q.send(c[1])
            elsif c == :notes
              row << [ q.send(c), q.send(:nomenclature_note_en) ].compact_blank.join('; ')
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

  def self.filter_is_current(set)
    if set == 'current'
      return where(is_current: true)
    end

    all
  end

  def self.filter_geo_entities(filters)
    if filters.key?('geo_entities_ids')
      geo_entities_ids = GeoEntity.nodes_and_descendants(
        filters['geo_entities_ids']
      ).map(&:id)

      return where(geo_entity_id: geo_entities_ids)
    end

    all
  end

  def self.filter_taxon_concepts(filters)
    if filters.key?('taxon_concepts_ids')
      conds_str = <<-SQL.squish
        ARRAY[
          taxon_concepts_mview.id, taxon_concepts_mview.family_id,
          taxon_concepts_mview.order_id, taxon_concepts_mview.class_id,
          taxon_concepts_mview.phylum_id, taxon_concepts_mview.kingdom_id
        ] && ARRAY[?]
        OR trade_restrictions.taxon_concept_id IS NULL
      SQL

      return where(conds_str, filters['taxon_concepts_ids'].map(&:to_i))
    end

    all
  end

  def self.filter_years(filters)
    if filters.key?('years')
      return where(
        'EXTRACT(YEAR FROM trade_restrictions.start_date)::INTEGER IN (?)',
        filters['years'].map(&:to_i)
      )
    end

    all
  end

private

  def touch_taxa_with_applicable_distribution
    update_stmt = TaxonConcept.send(
      :sanitize_sql_array, [
        "UPDATE taxon_concepts
      SET dependents_updated_at = CURRENT_TIMESTAMP, dependents_updated_by_id = :updated_by_id
      FROM distributions
      WHERE distributions.taxon_concept_id = taxon_concepts.id
      AND distributions.geo_entity_id IN (:geo_entity_id)",
        updated_by_id: updated_by_id,
        geo_entity_id: [
          # Rails 5.1 to 5.2
          # DEPRECATION WARNING: The behavior of `attribute_was` inside of after callbacks will be changing in the next version of Rails.
          # The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now).
          # To maintain the current behavior, use `attribute_before_last_save` instead.
          #
          # DEPRECATION WARNING: The behavior of `attribute_changed?` inside of after callbacks will be changing in the next version of Rails.
          # The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now).
          # To maintain the current behavior, use `saved_change_to_attribute?` instead.
          #
          # DEPRECATION WARNING: The behavior of `changed_attributes` inside of after callbacks will be changing in the next version of Rails.
          # The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now).
          # To maintain the current behavior, use `saved_changes.transform_values(&:first)` instead.
          #
          # == Original code ==
          # geo_entity_id, geo_entity_id_was
          # == Changed to fix deprecation warnings ==
          geo_entity_id, geo_entity_id_before_last_save
        ].compact.uniq
      ]
    )
    TaxonConcept.connection.execute update_stmt
  end

  def touch_descendants
    update_stmt = TaxonConcept.send(
      :sanitize_sql_array, [
        "UPDATE taxon_concepts
      SET dependents_updated_at = CURRENT_TIMESTAMP, dependents_updated_by_id = :updated_by_id
      WHERE data IS NOT NULL
      AND ARRAY[
        (data->'species_id')::INT,
        (data->'genus_id')::INT,
        (data->'subfamily_id')::INT,
        (data->'family_id')::INT,
        (data->'order_id')::INT
      ] && ARRAY[:taxon_concept_id] ",
        updated_by_id: updated_by_id,
        taxon_concept_id: [
          # Rails 5.1 to 5.2
          # DEPRECATION WARNING: The behavior of `attribute_was` inside of after callbacks will be changing in the next version of Rails.
          # The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now).
          # To maintain the current behavior, use `attribute_before_last_save` instead.
          #
          # DEPRECATION WARNING: The behavior of `attribute_changed?` inside of after callbacks will be changing in the next version of Rails.
          # The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now).
          # To maintain the current behavior, use `saved_change_to_attribute?` instead.
          #
          # DEPRECATION WARNING: The behavior of `changed_attributes` inside of after callbacks will be changing in the next version of Rails.
          # The new return value will reflect the behavior of calling the method after `save` returned (e.g. the opposite of what it returns now).
          # To maintain the current behavior, use `saved_changes.transform_values(&:first)` instead.
          #
          # == Original code ==
          # taxon_concept_id, taxon_concept_id_was
          # == Changed to fix deprecation warnings ==
          taxon_concept_id, taxon_concept_id_before_last_save
        ].compact.uniq
      ]
    )
    TaxonConcept.connection.execute(update_stmt)
  end
end
