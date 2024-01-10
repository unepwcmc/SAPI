require 'spec_helper'
describe Species::SpeciesReferenceOutputExport do
  describe :path do
    subject {
      Species::SpeciesReferenceOutputExport.new({})
    }
    specify { subject.path.should == "public/downloads/species_reference_output/" }
  end
  describe :export do
    context "when no results" do
      subject {
        Species::SpeciesReferenceOutputExport.new({})
      }
      specify { subject.export.should be_falsey }
    end
    context "when results" do
      before(:each) {
        species = create_cites_eu_species
        FileUtils.mkpath(
          File.expand_path("spec/public/downloads/species_reference_output")
        )
        Species::SpeciesReferenceOutputExport.any_instance.stub(:path).
          and_return("spec/public/downloads/species_reference_output/")
      }
      after(:each) {
        FileUtils.remove_dir("spec/public/downloads/species_reference_output", true)
      }
      subject {
        Species::SpeciesReferenceOutputExport.new({})
      }
      context "when file not cached" do
        specify {
          subject.export
          File.file?(subject.file_name).should be_truthy
        }
      end
      context "when file cached" do
        specify {
          FileUtils.touch(subject.file_name)
          subject.should_not_receive(:to_csv)
          subject.export
        }
      end
    end
  end
end
