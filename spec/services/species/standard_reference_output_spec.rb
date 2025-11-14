require 'spec_helper'
describe Species::StandardReferenceOutputExport do
  describe :path do
    subject do
      Species::StandardReferenceOutputExport.new({})
    end

    specify { expect(subject.path).to eq('public/downloads/standard_reference_output/') }
  end

  describe :export, cache: true do
    context 'when no results' do
      subject do
        Species::StandardReferenceOutputExport.new({})
      end

      specify { expect(subject.export).to be_falsey }
    end

    context 'when results' do
      before(:each) do
        create_cites_eu_species

        FileUtils.mkpath(
          File.expand_path('spec/public/downloads/standard_reference_output')
        )

        allow_any_instance_of(Species::StandardReferenceOutputExport).to receive(:path).
          and_return('spec/public/downloads/standard_reference_output/')
      end

      after(:each) do
        FileUtils.remove_dir('spec/public/downloads/standard_reference_output', true)
      end

      subject do
        Species::StandardReferenceOutputExport.new({})
      end

      context 'when file not cached' do
        specify do
          subject.export

          expect(File.file?(subject.file_name)).to be_truthy
        end
      end

      context 'when file cached' do
        specify do
          FileUtils.touch(subject.file_name)

          expect(subject).not_to receive(:to_csv)

          subject.export
        end
      end
    end
  end
end
