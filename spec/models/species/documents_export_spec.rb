require 'spec_helper'
describe Species::DocumentsExport do
  describe :path do
    subject {
      Species::DocumentsExport.new({})
    }
    specify { subject.path.should == "public/downloads/documents/" }
  end
  SPEC_DOCUMENTS_DOWNLOAD_PATH = "spec/public/downloads/documents"
  describe :export do
    before(:each) do
      FileUtils.mkpath(
        File.expand_path("#{SPEC_DOCUMENTS_DOWNLOAD_PATH}")
      )
      Species::DocumentsExport.any_instance.stub(:path).
        and_return("#{SPEC_DOCUMENTS_DOWNLOAD_PATH}/")
    end
    after(:each) do
      FileUtils.remove_dir("#{SPEC_DOCUMENTS_DOWNLOAD_PATH}", true)
    end
    context "when no results" do
      before(:each){
        FileUtils.rm_rf(Dir.glob("#{SPEC_DOCUMENTS_DOWNLOAD_PATH}/*"))
      }
      subject {
        Species::DocumentsExport.new({})
      }
      specify "when file not cached it should not be generated" do
        subject.export.should be_false
      end
    end
    context "when results" do
      before(:each){
        ActiveRecord::Relation.any_instance.stub(:any?).and_return(true)
      }
      subject {
        Species::DocumentsExport.new({})
      }
      specify "when file not cached it should be generated" do
        subject.export
        File.file?(subject.file_name).should be_true
      end
      specify "when file cached it should not be generated" do
        FileUtils.touch(subject.file_name)
        subject.should_not_receive(:to_csv)
        subject.export
      end
    end
  end
end
