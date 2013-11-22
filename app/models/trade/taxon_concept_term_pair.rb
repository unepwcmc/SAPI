# == Schema Information
#
# Table name: trade_taxon_concept_term_pairs
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer
#  term_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Trade::TaxonConceptTermPair < ActiveRecord::Base
  attr_accessible :taxon_concept_id, :term_id

  belongs_to :taxon_concept
  belongs_to :term, :class_name => "TradeCode"
end
