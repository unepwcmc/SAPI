require 'spec_helper'
describe Species::TaxonConceptsNamesExport do
  describe :path do
    subject do
      Species::TaxonConceptsNamesExport.new({})
    end

    specify { expect(subject.path).to eq('public/downloads/taxon_concepts_names/') }
  end

  describe :export, cache: true do
    context 'when no results' do
      subject do
        Species::TaxonConceptsNamesExport.new({})
      end

      specify { expect(subject.export).to be_falsey }
    end

    context 'when results' do
      before(:each) do
        create(:taxon_concept)
        FileUtils.mkpath(
          File.expand_path('spec/public/downloads/taxon_concepts_names')
        )
        allow_any_instance_of(Species::TaxonConceptsNamesExport).to receive(:path).
          and_return('spec/public/downloads/taxon_concepts_names/')
      end

      after(:each) do
        FileUtils.remove_dir('spec/public/downloads/taxon_concepts_names', true)
      end

      subject do
        Species::TaxonConceptsNamesExport.new({})
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
