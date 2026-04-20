require 'spec_helper'
describe Species::CommonNamesExport do
  describe :path do
    subject do
      Species::CommonNamesExport.new({})
    end

    specify do
      expect(subject.path).to eq('public/downloads/common_names/')
    end
  end

  describe :export, :cache do
    context 'when no results' do
      subject do
        Species::CommonNamesExport.new({})
      end

      specify do
        expect(subject.export).to be_falsey
      end
    end

    context 'when results' do
      subject do
        Species::CommonNamesExport.new({})
      end

      before do
        create_cites_eu_species

        FileUtils.mkpath(
          File.expand_path('spec/public/downloads/common_names')
        )

        allow_any_instance_of(Species::CommonNamesExport).to receive(:path).
          and_return('spec/public/downloads/common_names/')
      end

      after do
        FileUtils.remove_dir('spec/public/downloads/common_names', true)
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
