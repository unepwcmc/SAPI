# == Schema Information
#
# Table name: trade_taxon_concept_code_pairs
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer
#  trade_code_id    :integer
#  trade_code_type  :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Trade::TaxonConceptTermPair < ActiveRecord::Base
  attr_accessible :taxon_concept_id, :term_id

  belongs_to :taxon_concept
  belongs_to :term, :class_name => "TradeCode"
end
