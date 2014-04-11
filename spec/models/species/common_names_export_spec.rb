require 'spec_helper'
describe Species::CommonNamesExport do
  describe :path do
    subject {
      Species::CommonNamesExport.new({})
    }
    specify { subject.path.should == "public/downloads/common_names/" }
  end
  describe :export do
    context "when no results" do
      subject {
        Species::CommonNamesExport.new({})
      }
      specify { subject.export.should be_false }
    end
    context "when results" do
      before(:each){
        species = create_cites_eu_species
        FileUtils.mkpath(
          File.expand_path("spec/public/downloads/common_names")
        )
        Species::CommonNamesExport.any_instance.stub(:path).
          and_return("spec/public/downloads/common_names/")
      }
      after(:each){
        FileUtils.remove_dir("spec/public/downloads/common_names", true)
      }
      subject {
        Species::CommonNamesExport.new({})
      }
      context "when file not cached" do
        specify {
          subject.export
          File.file?(subject.file_name).should be_true
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
