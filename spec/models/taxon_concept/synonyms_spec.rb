require 'spec_helper'

describe TaxonConcept do
  describe :accepted_taxon_concept do
    let(:accepted_tc){ create(:species) }
    let(:synonym_tc){
      synonym = create(:species, :name_status => 'S')
      create(
        :has_synonym,
        :taxon_concept => accepted_tc,
        :other_taxon_concept => synonym
      )
      synonym
    }

    specify{ synonym_tc.accepted_taxon_concept.should == accepted_tc }
  end
end