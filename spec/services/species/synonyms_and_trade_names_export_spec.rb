require 'spec_helper'
describe Species::SynonymsAndTradeNamesExport do
  describe :path do
    subject {
      Species::SynonymsAndTradeNamesExport.new({})
    }
    specify { expect(subject.path).to eq("public/downloads/synonyms_and_trade_names/") }
  end
  describe :export do
    context "when no results" do
      subject {
        Species::SynonymsAndTradeNamesExport.new({})
      }
      specify { expect(subject.export).to be_falsey }
    end
    context "when results" do
      before(:each) {
        species = create_cites_eu_species
        synonym = create_cites_eu_species(name_status: 'S')
        create(:taxon_relationship,
          taxon_concept: species,
          other_taxon_concept: synonym,
          taxon_relationship_type: synonym_relationship_type
        )
        FileUtils.mkpath(
          File.expand_path("spec/public/downloads/synonyms_and_trade_names")
        )
        allow_any_instance_of(Species::SynonymsAndTradeNamesExport).to receive(:path).
          and_return("spec/public/downloads/synonyms_and_trade_names/")
      }
      after(:each) {
        FileUtils.remove_dir("spec/public/downloads/synonyms_and_trade_names", true)
      }
      subject {
        Species::SynonymsAndTradeNamesExport.new({})
      }
      context "when file not cached" do
        specify {
          subject.export
          expect(File.file?(subject.file_name)).to be_truthy
        }
      end
      context "when file cached" do
        specify {
          FileUtils.touch(subject.file_name)
          expect(subject).not_to receive(:to_csv)
          subject.export
        }
      end
    end
  end
end
