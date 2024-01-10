require 'spec_helper'
describe Species::TaxonConceptsNamesExport do
  describe :path do
    subject {
      Species::TaxonConceptsNamesExport.new({})
    }
    specify { subject.path.should == "public/downloads/taxon_concepts_names/" }
  end
  describe :export do
    context "when no results" do
      subject {
        Species::TaxonConceptsNamesExport.new({})
      }
      specify { subject.export.should be_falsey }
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
          File.file?(subject.file_name).should be_truthy
        }
      end
      context "when file cached" do
        specify {
          FileUtils.touch(subject.file_name)
          subject.should_not_receive(:to_csv)
          subject.export
        }
      end
    end
  end
end
