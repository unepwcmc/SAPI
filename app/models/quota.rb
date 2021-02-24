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
#  original_id                 :integer
#  updated_by_id               :integer
#  created_by_id               :integer
#  internal_notes              :text
#  nomenclature_note_en        :text
#  nomenclature_note_es        :text
#  nomenclature_note_fr        :text
#  applies_to_import           :boolean          default(FALSE), not null
#

class Quota < TradeRestriction

  attr_accessible :public_display

  validates :quota, :presence => true
  validates :quota, :numericality => { :greater_than_or_equal_to => -1.0 }
  validates :geo_entity_id, :presence => true

  # Each element of CSV columns can be either an array [display_text, method]
  # or a single symbol if the display text and the method are the same
  CSV_COLUMNS = [
    :year, :party, :quota,
    [:unit, :unit_name], :publication_date,
    :notes, :url
  ]

  def start_date_formatted
    start_date ? start_date.strftime('%d/%m/%Y') : Time.now.beginning_of_year.strftime("%d/%m/%Y")
  end

  def end_date_formatted
    end_date ? end_date.strftime('%d/%m/%Y') : Time.now.end_of_year.strftime("%d/%m/%Y")
  end

  def self.search(query)
    if query.present?
      where("UPPER(geo_entities.name_en) LIKE UPPER(:query)
            OR UPPER(geo_entities.iso_code2) LIKE UPPER(:query)
            OR trade_restrictions.start_date::text LIKE :query
            OR trade_restrictions.end_date::text LIKE :query
            OR UPPER(trade_restrictions.notes) LIKE UPPER(:query)
            OR UPPER(taxon_concepts.full_name) LIKE UPPER(:query)",
            :query => "%#{query}%").
      joins(<<-SQL
          LEFT JOIN taxon_concepts
            ON taxon_concepts.id = trade_restrictions.taxon_concept_id
          LEFT JOIN geo_entities
            ON geo_entities.id = trade_restrictions.geo_entity_id
        SQL
      )
    else
      all
    end
  end

  def self.years_array
    self.select('EXTRACT(year from start_date)::VARCHAR years').
          group(:years).order('years DESC').map(&:years)
  end

  def self.count_matching(params)
    Quota.where(
      [
        "EXTRACT(year from start_date)::INTEGER = :year
        AND ((:excluded_geo_entities) IS NULL OR geo_entity_id NOT IN (:excluded_geo_entities))
        AND ((:included_geo_entities) IS NULL OR geo_entity_id IN (:included_geo_entities))
        AND ((:excluded_taxon_concepts) IS NULL OR taxon_concept_id NOT IN (:excluded_taxon_concepts))
        AND ((:included_taxon_concepts) IS NULL OR taxon_concept_id IN (:included_taxon_concepts))
        AND is_current = true",
        :year => params[:year].to_i,
        :excluded_geo_entities => params[:excluded_geo_entities_ids].present? ?
          params[:excluded_geo_entities_ids].map(&:to_i) : nil,
        :included_geo_entities => params[:included_geo_entities_ids].present? ?
          params[:included_geo_entities_ids].map(&:to_i) : nil,
        :excluded_taxon_concepts => params[:excluded_taxon_concepts_ids].present? ?
          params[:excluded_taxon_concepts_ids].split(",").map(&:to_i) : nil,
        :included_taxon_concepts => params[:included_taxon_concepts_ids].present? ?
          params[:included_taxon_concepts_ids].split(",").map(&:to_i) : nil
      ]
    ).count
  end
end
