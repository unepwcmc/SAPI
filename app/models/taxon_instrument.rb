class TaxonInstrument < ActiveRecord::Base
  attr_accessible :effective_from, :instrument_id, :taxon_concept_id

  belongs_to :instrument
  belongs_to :taxon_concept

  def effective_from_formatted
    effective_from ? effective_from.strftime('%d/%m/%Y') : ''
  end
end
