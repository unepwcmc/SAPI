# == Schema Information
#
# Table name: geo_entities
#
#  id                 :integer          not null, primary key
#  is_current         :boolean          default(TRUE)
#  iso_code2          :string(255)
#  iso_code3          :string(255)
#  legacy_type        :string(255)
#  long_name          :string(255)
#  name_en            :string(255)      not null
#  name_es            :string(255)
#  name_fr            :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  geo_entity_type_id :integer          not null
#  legacy_id          :integer
#
# Indexes
#
#  index_geo_entities_on_geo_entity_type_id  (geo_entity_type_id)
#  index_geo_entities_on_iso_code2           (iso_code2) UNIQUE WHERE (iso_code2 IS NOT NULL)
#  index_geo_entities_on_iso_code3           (iso_code3) UNIQUE WHERE (iso_code3 IS NOT NULL)
#
# Foreign Keys
#
#  geo_entities_geo_entity_type_id_fk  (geo_entity_type_id => geo_entity_types.id)
#

class GeoEntity < ApplicationRecord
  include Changeable
  include Deletable
  extend Mobility
  # Migrated to controller (Strong Parameters)
  # attr_accessible :geo_entity_type_id, :iso_code2, :iso_code3,
  #   :legacy_id, :legacy_type, :long_name, :name_en, :name_es, :name_fr,
  #   :is_current
  translates :name
  belongs_to :geo_entity_type
  has_many :geo_relationships
  has_many :distributions
  has_many :designation_geo_entities, dependent: :destroy
  has_many :designations, through: :designation_geo_entities
  has_many :quotas
  has_many :eu_opinions
  has_many :eu_suspensions
  has_many :exported_shipments, class_name: 'Trade::Shipment',
    foreign_key: :exporter_id
  has_many :imported_shipments, class_name: 'Trade::Shipment',
    foreign_key: :importer_id
  has_many :originated_shipments, class_name: 'Trade::Shipment',
    foreign_key: :country_of_origin_id
  has_many :document_citation_geo_entities, dependent: :destroy
  has_many :users
  has_many :cites_processes
  has_many :eu_country_dates

  # ISO-3166-1-alpha-2 codes MUST be of length 2 and MUST be unique, where they
  # exist
  validates :iso_code2,
    uniqueness: true,
    length: { is: 2 },
    format: { with: /\A[A-Z]+\z/, message: 'must be uppercase letters only' },
    allow_nil: true

  # countries MUST have an ISO-3166-1-alpha-2 code
  validates :iso_code2,
    presence: true,
    if: :is_country?

  # ISO-3166-1-alpha-3 codes MUST be of length 3 and MUST be unique, where they
  # exist, but we've not actually imported any yet.
  validates :iso_code3,
    uniqueness: true,
    length: { is: 3 },
    format: { with: /\A[A-Z]+\z/, message: 'must be uppercase letters only' },
    allow_nil: true

  # Remove leading and trailing spaces from ISO-3166-1
  normalizes :iso_code2, with: ->(value) { value&.strip&.upcase&.presence }
  normalizes :iso_code3, with: ->(value) { value&.strip&.upcase&.presence }

  # geo entities containing those given by ids
  scope :containing_geo_entities, lambda { |geo_entity_ids|
    select("#{table_name}.*").
      joins(geo_relationships: [ :geo_relationship_type, :related_geo_entity ]).
      where("geo_relationship_types.name = '#{GeoRelationshipType::CONTAINS}'").
      where('related_geo_entities_geo_relationships.id' => geo_entity_ids)
  }

  # geo entities contained in those given by ids
  scope :contained_geo_entities, lambda { |geo_entity_ids|
    select('related_geo_entities_geo_relationships.*').
      where(id: geo_entity_ids).
      joins(geo_relationships: [ :geo_relationship_type, :related_geo_entity ]).
      where("geo_relationship_types.name = '#{GeoRelationshipType::CONTAINS}'")
  }

  scope :current, -> { where(is_current: true) }

  after_commit :geo_entity_search_increment_cache_iterator

  def self.nodes_and_descendants(nodes_ids = [])
    joins_sql = <<-SQL.squish
      INNER JOIN (
        WITH RECURSIVE search_tree(id) AS (
            SELECT id
            FROM #{table_name}
            WHERE id IN (?)
          UNION
            SELECT other_geo_entities.id
            FROM search_tree
            JOIN geo_relationships
              ON geo_relationships.geo_entity_id = search_tree.id
            JOIN geo_relationship_types
              ON geo_relationship_types.id = geo_relationships.geo_relationship_type_id
              AND geo_relationship_types.name = '#{GeoRelationshipType::CONTAINS}'
            JOIN geo_entities other_geo_entities
              ON geo_relationships.other_geo_entity_id = other_geo_entities.id
        )
        SELECT id FROM search_tree
      ) nodes_and_descendants_ids ON #{table_name}.id = nodes_and_descendants_ids.id
      SQL
    joins(
      sanitize_sql_array([ joins_sql, nodes_ids ])
    )
  end

  def is_country?
    geo_entity_type.name == GeoEntityType::COUNTRY
  end

  def containing_geo_entities
    GeoEntity.containing_geo_entities(self.id)
  end

  def contained_geo_entities
    GeoEntity.contained_geo_entities(self.id)
  end

  def as_json(options = {})
    super(only: [ :id, :iso_code2, :is_current ], methods: [ :name ])
  end

  def self.search(query)
    self.ilike_search(
      query, [
        :name_en,
        :name_fr,
        :name_es,
        :long_name,
        :iso_code3,
        :iso_code2
      ]
    )
  end

private

  def dependent_objects_map
    {
      'connected geo entities' => geo_relationships,
      'distributions' => distributions,
      'quotas' => quotas,
      'EU suspensions' => eu_suspensions,
      'EU opinions' => eu_opinions,
      'shipments (exporter)' => exported_shipments,
      'shipments (importer)' => imported_shipments,
      'shipments (origin)' => originated_shipments
    }
  end

  def geo_entity_search_increment_cache_iterator
    GeoEntitySearch.increment_cache_iterator
  end
end
