# == Schema Information
#
# Table name: taxon_instruments
#
#  id               :integer          not null, primary key
#  effective_from   :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  created_by_id    :integer
#  instrument_id    :integer
#  taxon_concept_id :integer
#  updated_by_id    :integer
#
# Indexes
#
#  index_taxon_instruments_on_created_by_id     (created_by_id)
#  index_taxon_instruments_on_instrument_id     (instrument_id)
#  index_taxon_instruments_on_taxon_concept_id  (taxon_concept_id)
#  index_taxon_instruments_on_updated_by_id     (updated_by_id)
#
# Foreign Keys
#
#  taxon_instruments_created_by_id_fk     (created_by_id => users.id)
#  taxon_instruments_instrument_id_fk     (instrument_id => instruments.id)
#  taxon_instruments_taxon_concept_id_fk  (taxon_concept_id => taxon_concepts.id)
#  taxon_instruments_updated_by_id_fk     (updated_by_id => users.id)
#

class TaxonInstrument < ApplicationRecord
  include Changeable
  include TrackWhoDoesIt
  # Migrated to controller (Strong Parameters)
  # attr_accessible :effective_from, :instrument_id, :taxon_concept_id

  belongs_to :instrument
  belongs_to :taxon_concept

  def effective_from_formatted
    effective_from ? effective_from.strftime('%d/%m/%Y') : ''
  end
end
