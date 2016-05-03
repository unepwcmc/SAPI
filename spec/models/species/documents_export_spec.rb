require 'spec_helper'
describe Species::DocumentsExport, sidekiq: :inline do
  SPEC_DOWNLOADS_PATH = "spec/public/downloads/documents"
  describe :path do
    subject {
      Species::DocumentsExport.new({})
    }
    specify { subject.path.should == "public/downloads/documents/" }
  end
  describe :export do
    context "when no results" do
      subject {
        Species::DocumentsExport.new({})
      }
      specify { subject.export.should be_false }
    end
    context "when results" do
      before(:each){
        @document = create(:proposal)
        FileUtils.mkpath(
          File.expand_path(SPEC_DOWNLOADS_PATH)
        )
        Species::DocumentsExport.any_instance.stub(:path).
          and_return(SPEC_DOWNLOADS_PATH + '/')
      }
      after(:each){
        FileUtils.remove_dir(SPEC_DOWNLOADS_PATH, true)
      }
      subject {
        Species::DocumentsExport.new({})
      }
      specify "when file not cached it is generated" do
        subject.export
        File.file?(subject.file_name).should be_true
      end
      specify "when file cached it is not generated" do
        FileUtils.touch(subject.file_name)
        subject.should_not_receive(:to_csv)
        subject.export
      end
    end
  end
end
