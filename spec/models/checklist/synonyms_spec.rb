require 'spec_helper'

describe Checklist do
  include_context "Caiman latirostris"

  context "when synonyms displayed" do
    before(:all) do
      @checklist = Checklist::Checklist.new({
        :output_layout => :alphabetical,
        :show_synonyms => '1'
      })
      @taxon_concepts = @checklist.results
    end

    it "should return Alligator cynocephalus as synonym for Caiman latirostris" do
      @caiman_latirostris = @taxon_concepts.select { |e| e.full_name == @species.full_name }.first
      @caiman_latirostris.synonyms.should == ['Alligator cynocephalus']
    end

  end

end
