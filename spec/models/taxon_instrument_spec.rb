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

require 'spec_helper'

describe TaxonInstrument do
  pending "add some examples to (or delete) #{__FILE__}"
end
