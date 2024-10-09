# == Schema Information
#
# Table name: distributions
#
#  id               :integer          not null, primary key
#  internal_notes   :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  created_by_id    :integer
#  geo_entity_id    :integer          not null
#  taxon_concept_id :integer          not null
#  updated_by_id    :integer
#
# Indexes
#
#  index_distributions_on_taxon_concept_id  (taxon_concept_id)
#
# Foreign Keys
#
#  distributions_created_by_id_fk                  (created_by_id => users.id)
#  distributions_updated_by_id_fk                  (updated_by_id => users.id)
#  taxon_concept_geo_entities_geo_entity_id_fk     (geo_entity_id => geo_entities.id)
#  taxon_concept_geo_entities_taxon_concept_id_fk  (taxon_concept_id => taxon_concepts.id)
#
FactoryBot.define do
  factory :geo_relationship_type do
    sequence(:name) { |n| "CONTAINS#{n}" }
  end

  factory :geo_relationship do
    geo_relationship_type
    geo_entity
    related_geo_entity
  end

  factory :geo_entity_type do
    name { 'COUNTRY' }
  end

  factory :geo_entity, aliases: [ :related_geo_entity, :trading_country, :importer, :exporter ] do
    geo_entity_type
    name_en { 'Wonderland' }
    sequence(:iso_code2) { |n| [ n, n + 1 ].map { |i| (65 + (i % 26)).chr }.join }
    is_current { true }
  end

  factory :distribution do
    taxon_concept
    geo_entity
  end
end
