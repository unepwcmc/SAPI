# == Schema Information
#
# Table name: trade_taxon_concept_term_pairs
#
#  id               :integer          not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  taxon_concept_id :integer
#  term_id          :integer
#
# Indexes
#
#  idx_on_taxon_concept_id_term_id_7d43d0e952  (taxon_concept_id,term_id) UNIQUE
#  idx_on_term_id_taxon_concept_id_884cb66b5b  (term_id,taxon_concept_id) UNIQUE
#
# Foreign Keys
#
#  trade_taxon_concept_code_pairs_taxon_concept_id_fk  (taxon_concept_id => taxon_concepts.id)
#  trade_taxon_concept_code_pairs_term_id_fk           (term_id => trade_codes.id)
#

class Trade::TaxonConceptTermPair < ApplicationRecord
  # Migrated to controller (Strong Parameters)
  # attr_accessible :taxon_concept_id, :term_id
  validates :taxon_concept_id, uniqueness: { scope: :term_id }

  belongs_to :taxon_concept
  belongs_to :term, class_name: 'TradeCode'

  def self.search(query)
    return all if query.blank?

    ilike_search(
      query, [
        TaxonConcept.arel_table['full_name'],
        TradeCode.arel_table['code']
      ]
    ).left_joins([ :taxon_concept, :term ])
  end
end
