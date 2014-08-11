require 'spec_helper'

describe Document do

  describe :create do
    context "when date is blank" do
      let(:document){
        build(
          :document,
          :date => nil
        )
      }
      specify { expect(document).to be_invalid }
      specify { expect(document).to have(1).error_on(:date) }
    end
    context "setting title from filename" do
      let(:document){ create(:document) }
      specify{ expect(document.title).to eq('Annual report upload exporter') }
    end
  end
end