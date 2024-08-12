# == Schema Information
#
# Table name: taxon_concepts
#
#  id                         :integer          not null, primary key
#  author_year                :string(255)
#  data                       :hstore
#  dependents_updated_at      :datetime
#  full_name                  :string(255)
#  internal_nomenclature_note :text
#  legacy_trade_code          :string(255)
#  legacy_type                :string(255)
#  listing                    :hstore
#  name_status                :string(255)      default("A"), not null
#  nomenclature_note_en       :text
#  nomenclature_note_es       :text
#  nomenclature_note_fr       :text
#  notes                      :text
#  taxonomic_position         :string(255)      default("0"), not null
#  touched_at                 :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  created_by_id              :integer
#  dependents_updated_by_id   :integer
#  kew_id                     :integer
#  legacy_id                  :integer
#  parent_id                  :integer
#  rank_id                    :integer          not null
#  taxon_name_id              :integer          not null
#  taxonomy_id                :integer          default(1), not null
#  updated_by_id              :integer
#
# Indexes
#
#  index_taxon_concepts_on_created_by_id_and_updated_by_id  (created_by_id,updated_by_id)
#  index_taxon_concepts_on_full_name                        (upper((full_name)::text) text_pattern_ops)
#  index_taxon_concepts_on_legacy_trade_code                (legacy_trade_code)
#  index_taxon_concepts_on_name_status                      (name_status)
#  index_taxon_concepts_on_parent_id                        (parent_id)
#  index_taxon_concepts_on_taxonomy_id                      (taxonomy_id)
#
# Foreign Keys
#
#  taxon_concepts_created_by_id_fk             (created_by_id => users.id)
#  taxon_concepts_dependents_updated_by_id_fk  (dependents_updated_by_id => users.id)
#  taxon_concepts_parent_id_fk                 (parent_id => taxon_concepts.id)
#  taxon_concepts_rank_id_fk                   (rank_id => ranks.id)
#  taxon_concepts_taxon_name_id_fk             (taxon_name_id => taxon_names.id)
#  taxon_concepts_taxonomy_id_fk               (taxonomy_id => taxonomies.id)
#  taxon_concepts_updated_by_id_fk             (updated_by_id => users.id)
#
FactoryBot.define do
  factory :taxon_concept, :aliases => [:other_taxon_concept] do
    taxonomy
    rank
    taxon_name
    taxonomic_position { '1' }
    name_status { 'A' }
    data {}
    listing {}
    before(:create) { |tc|
      if tc.parent.nil? && ['A', 'N'].include?(tc.name_status) && tc.rank.try(:name) != 'KINGDOM'
        tc.parent = create(
          :taxon_concept,
          taxonomy: tc.taxonomy,
          name_status: 'A',
          rank: create(:rank, name: tc.rank.parent_rank_name) # this should not produce duplicates
        )
      end
    }
  end
end
