require 'spec_helper'

describe TaxonConcept do
  describe :accepted_taxon_concept do
    let(:accepted_tc){ create(:species) }
    let(:synonym_tc){
      create(:species, :name_status => 'S')
    }
    let!(:synonym_rel){
      create(
        :has_synonym,
        :taxon_concept => accepted_tc,
        :other_taxon_concept => synonym_tc
      )
    }

    specify{ synonym_tc.accepted_taxon_concept.should == accepted_tc }
  end
end