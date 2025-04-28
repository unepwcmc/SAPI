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

class Quota < TradeRestriction
  include Changeable
  # Migrated to controller (Strong Parameters)
  # attr_accessible :public_display

  validates :quota, presence: true
  validates :quota, numericality: { greater_than_or_equal_to: -1.0 }
  validates :geo_entity_id, presence: true

  after_commit :async_downloads_cache_cleanup, on: :destroy

  # Each element of CSV columns can be either an array [display_text, method]
  # or a single symbol if the display text and the method are the same
  CSV_COLUMNS = [
    :year, :party, :quota,
    [ :unit, :unit_name ], :publication_date,
    :notes, :url
  ]

  def start_date_formatted
    start_date ? start_date.strftime('%d/%m/%Y') : Time.now.beginning_of_year.strftime('%d/%m/%Y')
  end

  def end_date_formatted
    end_date ? end_date.strftime('%d/%m/%Y') : Time.now.end_of_year.strftime('%d/%m/%Y')
  end

  def self.years_array
    self.select('EXTRACT(year from start_date)::VARCHAR years').
      group(:years).order('years DESC').map(&:years)
  end

  def self.count_matching(params)
    Quota.where(
      [
        (
          <<-SQL.squish
            EXTRACT(year from start_date)::INTEGER = :year
            AND ((:excluded_geo_entities) IS NULL OR geo_entity_id NOT IN (:excluded_geo_entities))
            AND ((:included_geo_entities) IS NULL OR geo_entity_id IN (:included_geo_entities))
            AND ((:excluded_taxon_concepts) IS NULL OR taxon_concept_id NOT IN (:excluded_taxon_concepts))
            AND ((:included_taxon_concepts) IS NULL OR taxon_concept_id IN (:included_taxon_concepts))
            AND is_current = true
          SQL
        ),
        year: params[:year].to_i,
        excluded_geo_entities: params[:excluded_geo_entities_ids].present? ?
          params[:excluded_geo_entities_ids].map(&:to_i) : nil,
        included_geo_entities: params[:included_geo_entities_ids].present? ?
          params[:included_geo_entities_ids].map(&:to_i) : nil,
        excluded_taxon_concepts: params[:excluded_taxon_concepts_ids].present? ?
          params[:excluded_taxon_concepts_ids].split(',').map(&:to_i) : nil,
        included_taxon_concepts: params[:included_taxon_concepts_ids].present? ?
          params[:included_taxon_concepts_ids].split(',').map(&:to_i) : nil
      ]
    ).count
  end

private

  def async_downloads_cache_cleanup
    DownloadsCacheCleanupWorker.perform_async('quotas')
  end
end
