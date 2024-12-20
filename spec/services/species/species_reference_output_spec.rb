require 'spec_helper'
describe Species::SpeciesReferenceOutputExport do
  describe :path do
    subject do
      Species::SpeciesReferenceOutputExport.new({})
    end
    specify { expect(subject.path).to eq('public/downloads/species_reference_output/') }
  end
  describe :export do
    context 'when no results' do
      subject do
        Species::SpeciesReferenceOutputExport.new({})
      end
      specify { expect(subject.export).to be_falsey }
    end
    context 'when results' do
      before(:each) do
        species = create_cites_eu_species
        FileUtils.mkpath(
          File.expand_path('spec/public/downloads/species_reference_output')
        )
        allow_any_instance_of(Species::SpeciesReferenceOutputExport).to receive(:path).
          and_return('spec/public/downloads/species_reference_output/')
      end
      after(:each) do
        FileUtils.remove_dir('spec/public/downloads/species_reference_output', true)
      end
      subject do
        Species::SpeciesReferenceOutputExport.new({})
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
