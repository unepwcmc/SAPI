require 'spec_helper'
describe Species::DocumentsExport do
  describe :path do
    subject do
      Species::DocumentsExport.new({})
    end

    specify do
      expect(subject.path).to eq('public/downloads/documents/')
    end
  end

  SPEC_DOCUMENTS_DOWNLOAD_PATH = 'spec/public/downloads/documents'

  describe :export, cache: true do
    before(:each) do
      FileUtils.mkpath(
        File.expand_path("#{SPEC_DOCUMENTS_DOWNLOAD_PATH}")
      )
      allow_any_instance_of(Species::DocumentsExport).to receive(:path).
        and_return("#{SPEC_DOCUMENTS_DOWNLOAD_PATH}/")
    end

    after(:each) do
      FileUtils.remove_dir("#{SPEC_DOCUMENTS_DOWNLOAD_PATH}", true)
    end

    context 'when no results' do
      before(:each) do
        FileUtils.rm_rf(Dir.glob("#{SPEC_DOCUMENTS_DOWNLOAD_PATH}/*"))
      end

      subject do
        Species::DocumentsExport.new({})
      end

      specify 'when file not cached it should not be generated' do
        expect(subject.export).to be_falsey
      end
    end

    context 'when results' do
      # Commented as was causing issues and tests are pending anyway
      # before(:each) {
      #  create(:document)
      #  DocumentSearch.refresh_citations_and_documents
      # }
      # subject {
      #  Species::DocumentsExport.new({})
      # }
      pending 'when file not cached it should be generated' do
        subject.export
        expect(File.file?(subject.file_name)).to be_truthy
        expect(File.size(subject.file_name)).to be > 0
      end

      pending 'when file cached it should not be generated' do
        FileUtils.touch(subject.file_name)
        expect(subject).not_to receive(:to_csv)
        subject.export
      end
    end
  end
end
