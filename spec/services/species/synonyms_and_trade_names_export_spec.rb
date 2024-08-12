require 'spec_helper'
describe Species::SynonymsAndTradeNamesExport do
  describe :path do
    subject do
      Species::SynonymsAndTradeNamesExport.new({})
    end
    specify { expect(subject.path).to eq('public/downloads/synonyms_and_trade_names/') }
  end
  describe :export do
    context 'when no results' do
      subject do
        Species::SynonymsAndTradeNamesExport.new({})
      end
      specify { expect(subject.export).to be_falsey }
    end
    context 'when results' do
      before(:each) do
        species = create_cites_eu_species
        synonym = create_cites_eu_species(name_status: 'S')
        create(:taxon_relationship,
          taxon_concept: species,
          other_taxon_concept: synonym,
          taxon_relationship_type: synonym_relationship_type
        )
        FileUtils.mkpath(
          File.expand_path('spec/public/downloads/synonyms_and_trade_names')
        )
        allow_any_instance_of(Species::SynonymsAndTradeNamesExport).to receive(:path).
          and_return('spec/public/downloads/synonyms_and_trade_names/')
      end
      after(:each) do
        FileUtils.remove_dir('spec/public/downloads/synonyms_and_trade_names', true)
      end
      subject do
        Species::SynonymsAndTradeNamesExport.new({})
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
