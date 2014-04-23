require 'spec_helper'
describe Species::Search do
  include_context "Psittaciformes"
  describe :results do
    context "when searching by scientific name" do
      context "when subspecies never listed" do
        subject { Species::Search.new({:taxon_concept_query => 'amazona festiva'}).results }
        specify { subject.should_not include(@subspecies2_2_2_1)}
      end
    end
  end
end