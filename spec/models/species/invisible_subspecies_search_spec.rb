require 'spec_helper'
describe Species::Search do
  include_context "Psittaciformes"
  describe :results do
    context "when searching by scientific name" do
      context "when subspecies never listed" do
        subject { Species::Search.new({ :taxon_concept_query => 'amazona festiva festiva' }).results }
        specify { subject.should_not include(@subspecies2_2_2_1) }
        specify { subject.should include(@species2_2_2) }
      end
    end
  end
end
