require 'spec_helper'
describe Species::OrphanedTaxonConceptsExport do
  describe :path do
    subject {
      Species::OrphanedTaxonConceptsExport.new({})
    }
    specify { expect(subject.path).to eq("public/downloads/orphaned_taxon_concepts/") }
  end
  describe :export do
    context "when no results" do
      subject {
        Species::OrphanedTaxonConceptsExport.new({})
      }
      specify { expect(subject.export).to be_falsey }
    end
    context "when results" do
      before(:each) {
        tc = create(:taxon_concept)
        tc.update_attribute(:parent_id, nil) # skipping validations
        FileUtils.mkpath(
          File.expand_path("spec/public/downloads/orphaned_taxon_concepts")
        )
        Species::OrphanedTaxonConceptsExport.any_instance.stub(:path).
          and_return("spec/public/downloads/orphaned_taxon_concepts/")
      }
      after(:each) {
        FileUtils.remove_dir("spec/public/downloads/orphaned_taxon_concepts", true)
      }
      subject {
        Species::OrphanedTaxonConceptsExport.new({})
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
