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
      before(:each) {
        FileUtils.rm_rf(Dir.glob("#{SPEC_DOCUMENTS_DOWNLOAD_PATH}/*"))
      }
      subject {
        Species::DocumentsExport.new({})
      }
      specify "when file not cached it should not be generated" do
        subject.export.should be_falsey
      end
    end
    context "when results" do
      #Commented as was causing issues and tests are pending anyway
      #before(:each) {
      #  create(:document)
      #  DocumentSearch.refresh_citations_and_documents
      #}
      #subject {
      #  Species::DocumentsExport.new({})
      #}
      pending "when file not cached it should be generated" do
        subject.export
        File.file?(subject.file_name).should be_truthy
        File.size(subject.file_name).should be > 0
      end
      pending "when file cached it should not be generated" do
        FileUtils.touch(subject.file_name)
        subject.should_not_receive(:to_csv)
        subject.export
      end
    end
  end
end
