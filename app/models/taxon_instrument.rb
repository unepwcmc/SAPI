# == Schema Information
#
# Table name: taxon_instruments
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer
#  instrument_id    :integer
#  effective_from   :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class TaxonInstrument < ActiveRecord::Base
  attr_accessible :effective_from, :instrument_id, :taxon_concept_id

  belongs_to :instrument
  belongs_to :taxon_concept, :touch => true

  def effective_from_formatted
    effective_from ? effective_from.strftime('%d/%m/%Y') : ''
  end
end
