#Encoding: UTF-8
require 'spec_helper'

describe Checklist do
  include_context "Panax ginseng"
  include_context "Caiman latirostris"
  describe "specific_annotation_symbol" do
    before(:all) do
      @checklist = Checklist::Checklist.new({
        :output_layout => 'alphabetical',
        :locale => 'en'
      })
      @checklist.generate(0, 100)
      @taxon_concepts = @checklist.taxon_concepts_rel
    end
    context 'for species Caiman latirostris' do
      subject { @taxon_concepts.select{ |e| e.full_name == 'Caiman latirostris' }.first }
      specify { subject.specific_annotation_symbol.should == '1' }
    end
    context 'for species Panax ginseng' do
      subject { @taxon_concepts.select{ |e| e.full_name == 'Panax ginseng' }.first }
      specify { subject.specific_annotation_symbol.should == '2' }
    end
  end
end