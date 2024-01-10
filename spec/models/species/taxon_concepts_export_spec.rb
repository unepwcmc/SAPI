require 'spec_helper'
describe Species::TaxonConceptsNamesExport do
  describe :path do
    subject {
      Species::TaxonConceptsNamesExport.new({})
    }
    specify { expect(subject.path).to eq("public/downloads/taxon_concepts_names/") }
  end
  describe :export do
    context "when no results" do
      subject {
        Species::TaxonConceptsNamesExport.new({})
      }
      specify { expect(subject.export).to be_falsey }
    end
    context "when results" do
      before(:each) {
        create(:taxon_concept)
        FileUtils.mkpath(
          File.expand_path("spec/public/downloads/taxon_concepts_names")
        )
        Species::TaxonConceptsNamesExport.any_instance.stub(:path).
          and_return("spec/public/downloads/taxon_concepts_names/")
      }
      after(:each) {
        FileUtils.remove_dir("spec/public/downloads/taxon_concepts_names", true)
      }
      subject {
        Species::TaxonConceptsNamesExport.new({})
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
