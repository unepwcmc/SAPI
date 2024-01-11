require 'spec_helper'
describe Species::CommonNamesExport do
  describe :path do
    subject {
      Species::CommonNamesExport.new({})
    }
    specify { expect(subject.path).to eq("public/downloads/common_names/") }
  end
  describe :export do
    context "when no results" do
      subject {
        Species::CommonNamesExport.new({})
      }
      specify { expect(subject.export).to be_falsey }
    end
    context "when results" do
      before(:each) {
        species = create_cites_eu_species
        FileUtils.mkpath(
          File.expand_path("spec/public/downloads/common_names")
        )
        allow_any_instance_of(Species::CommonNamesExport).to receive(:path).
          and_return("spec/public/downloads/common_names/")
      }
      after(:each) {
        FileUtils.remove_dir("spec/public/downloads/common_names", true)
      }
      subject {
        Species::CommonNamesExport.new({})
      }
      context "when file not cached" do
        specify {
          subject.export
          expect(File.file?(subject.file_name)).to be_truthy
        }
      end
      context "when file cached" do
        specify {
          FileUtils.touch(subject.file_name)
          expect(subject).not_to receive(:to_csv)
          subject.export
        }
      end
    end
  end
end
