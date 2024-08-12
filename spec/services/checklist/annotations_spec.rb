require 'spec_helper'

describe Checklist do
  include_context "Panax ginseng"
  include_context "Caiman latirostris"
  describe "ann_symbol" do
    before(:all) do
      @checklist = Checklist::Checklist.new({
        output_layout: 'alphabetical',
        locale: 'en'
      })
      @taxon_concepts = @checklist.results
    end
    context 'for species Caiman latirostris' do
      subject { @taxon_concepts.select { |e| e.full_name == 'Caiman latirostris' }.first }
      specify { expect(subject.ann_symbol).to eq('1') }
    end
    context 'for species Panax ginseng' do
      subject { @taxon_concepts.select { |e| e.full_name == 'Panax ginseng' }.first }
      specify { expect(subject.ann_symbol).to eq('2') }
    end
  end
end
