require 'spec_helper'

describe Checklist do
  include_context "Arctocephalus"

  context "when filtering by name" do
    context "by scientific name" do
      subject {
        checklist = Checklist::Checklist.new({
          :scientific_name => "Arctocephalus townsendi",
          :output_layout => :taxonomic
        })
        checklist.results
      }
      specify {
        expect(subject.first.full_name).to eq(@species2.full_name)
        expect(subject.size).to eq(1)
      }
    end
    context "by common name" do
      subject {
        checklist = Checklist::Checklist.new({
          :scientific_name => "Guadalupe Fur Seal",
          :output_layout => :taxonomic
        })
        checklist.results
      }
      specify {
        expect(subject.first.full_name).to eq(@species2.full_name)
        expect(subject.size).to eq(1)
      }
    end
  end
end
