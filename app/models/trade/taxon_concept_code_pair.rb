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

class Trade::TaxonConceptCodePair < ActiveRecord::Base
  attr_accessible :taxon_concept_id, :trade_code_id, :trade_code_type

  belongs_to :taxon_concept
  belongs_to :trade_code
end
