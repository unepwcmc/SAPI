require 'spec_helper'
describe Species::OrphanedTaxonConceptsExport do
  describe :path do
    subject do
      Species::OrphanedTaxonConceptsExport.new({})
    end

    specify { expect(subject.path).to eq('public/downloads/orphaned_taxon_concepts/') }
  end

  describe :export, cache: true do
    context 'when no results' do
      subject do
        Species::OrphanedTaxonConceptsExport.new({})
      end

      specify { expect(subject.export).to be_falsey }
    end

    context 'when results' do
      before(:each) do
        tc = create(:taxon_concept)

        tc.update_attribute(:parent_id, nil) # skipping validations

        FileUtils.mkpath(
          File.expand_path('spec/public/downloads/orphaned_taxon_concepts')
        )

        allow_any_instance_of(Species::OrphanedTaxonConceptsExport).to receive(:path).
          and_return('spec/public/downloads/orphaned_taxon_concepts/')
      end

      after(:each) do
        FileUtils.remove_dir('spec/public/downloads/orphaned_taxon_concepts', true)
      end

      subject do
        Species::OrphanedTaxonConceptsExport.new({})
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
