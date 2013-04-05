require 'spec_helper'
describe ListingsExport do
  include_context "Canis lupus"
  describe :path do
    subject { 
      ListingsExport.new({
        :designation_id => cites.id
      })
    }
    specify {subject.path.should == "public/downloads/cites_listings/" }
  end
  describe :export do
    context "when no results" do
      subject { 
        ListingsExport.new({
          :designation_id => cites.id,
          :species_listings_ids => [cites_I.id],
          :geo_entities_ids => [poland.id]
        })
      }
      specify { subject.export.should be_false }       
    end
    context "when results" do
      before(:each){
        FileUtils.mkpath(
          File.expand_path("spec/public/downloads/cites_listings")
        )
        ListingsExport.any_instance.stub(:path).
          and_return("spec/public/downloads/cites_listings/")
      }
      after(:each){
        FileUtils.remove_dir("spec/public/downloads/cites_listings", true)
      }
      subject { 
        ListingsExport.new({
          :designation_id => cites.id,
          :species_listings_ids => [cites_I.id],
          :geo_entities_ids => [nepal.id]
        })
      }
      context "when file not cached" do
        specify {       
          subject.export
          File.file?(subject.file_name).should be_true
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
  describe :query do
    context "when Appendix I" do
      subject { 
        ListingsExport.new({
          :designation_id => [cites.id],
          :species_listings_ids => [cites_I.id]
        })
      }
      specify { subject.query.all.size.should == 1 }

      context "when Poland" do
        subject { 
          ListingsExport.new({
            :designation_id => cites.id,
            :species_listings_ids => [cites_I.id],
            :geo_entities_ids => [poland.id]
          })
        }
        specify { subject.query.all.size.should == 0 }      
      end

      context "when Nepal" do
        subject { 
          ListingsExport.new({
            :designation_id => cites.id,
            :species_listings_ids => [cites_I.id],
            :geo_entities_ids => [nepal.id]
          })
        }
        specify { subject.query.all.size.should == 1 }      
      end
    end
    context "when higher taxon ids" do
      subject { 
        ListingsExport.new({
          :designation_id => cites.id,
          :taxon_concepts_ids => [@family.id]
        })
      }
      specify { subject.query.all.size.should == 1 }       
    end
  end
end