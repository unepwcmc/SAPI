require 'spec_helper'
describe Species::Search do
  include_context "Canis lupus"
  describe :results do
    context "when searching by scientific name" do
      context "when subspecies previously listed " do
        subject { Species::Search.new({ :taxon_concept_query => 'canis lupus' }).results }
        specify { subject.should include(@subspecies) }
      end
    end
  end
end
