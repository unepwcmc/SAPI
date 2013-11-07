#Encoding: utf-8
require 'spec_helper'

describe TaxonConcept do
  describe :destroy do
    before(:each){ @taxon_concept = create_cms_species }
    context "when no dependent objects attached" do
      specify { @taxon_concept.destroy.should be_true }
    end
    context "when dependent objects attached" do
      context "when taxon instruments" do
        before(:each){ create(:taxon_instrument, :taxon_concept => @taxon_concept)}
        specify { @taxon_concept.destroy.should be_false }
      end
    end
  end
end
