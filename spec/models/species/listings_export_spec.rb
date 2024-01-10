require 'spec_helper'
describe Species::ListingsExport do
  include_context "Canis lupus"
  describe :path do
    subject {
      Species::ListingsExportFactory.new({
        :designation_id => cites.id
      })
    }
    specify { expect(subject.path).to eq("public/downloads/cites_listings/") }
  end
  describe :export do
    context "when no results" do
      subject {
        Species::ListingsExportFactory.new({
          :designation_id => cites.id,
          :species_listings_ids => [cites_I.id],
          :geo_entities_ids => [poland.id]
        })
      }
      specify { expect(subject.export).to be_falsey }
    end
    context "when results" do
      before(:each) {
        FileUtils.mkpath(
          File.expand_path("spec/public/downloads/cites_listings")
        )
        Species::ListingsExport.any_instance.stub(:path).
          and_return("spec/public/downloads/cites_listings/")
      }
      after(:each) {
        FileUtils.remove_dir("spec/public/downloads/cites_listings", true)
      }
      subject {
        Species::ListingsExportFactory.new({
          :designation_id => cites.id,
          :species_listings_ids => [cites_I.id],
          :geo_entities_ids => [nepal.id]
        })
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
  describe :query do
    context "when CITES" do
      context "when Appendix I" do
        subject {
          Species::ListingsExportFactory.new({
            :designation_id => cites.id,
            :species_listings_ids => [cites_I.id]
          })
        }
        specify { expect(subject.query.to_a.size).to eq(1) }

        context "when Poland" do
          subject {
            Species::ListingsExportFactory.new({
              :designation_id => cites.id,
              :species_listings_ids => [cites_I.id],
              :geo_entities_ids => [poland.id]
            })
          }
          specify { expect(subject.query.to_a.size).to eq(0) }
        end

        context "when Nepal" do
          subject {
            Species::ListingsExportFactory.new({
              :designation_id => cites.id,
              :species_listings_ids => [cites_I.id],
              :geo_entities_ids => [nepal.id]
            })
          }
          specify { expect(subject.query.to_a.size).to eq(1) }
        end
      end
      context "when higher taxon ids" do
        subject {
          Species::ListingsExportFactory.new({
            :designation_id => cites.id,
            :taxon_concepts_ids => [@family.id]
          })
        }
        specify { expect(subject.query.to_a.size).to eq(1) }
      end
      context "when implicitly listed subspecies present" do
        before(:each) do
          create_cites_eu_subspecies(
            :parent_id => @species.id
          )
          Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
        end
        subject {
          Species::ListingsExportFactory.new({
            :designation_id => cites.id,
            :taxon_concepts_ids => [@family.id]
          })
        }
        specify { expect(subject.query.to_a.size).to eq(1) }
      end
    end
    context "when EU" do
      context "when Annex A" do
        subject {
          Species::ListingsExportFactory.new({
            :designation_id => eu.id,
            :species_listings_ids => [eu_A.id]
          })
        }
        specify { expect(subject.query.to_a.size).to eq(1) }

        context "when Spain" do
          subject {
            Species::ListingsExportFactory.new({
              :designation_id => eu.id,
              :species_listings_ids => [eu_A.id],
              :geo_entities_ids => [spain.id]
            })
          }
          specify { expect(subject.query.to_a.size).to eq(0) }
        end

        context "when Nepal" do
          subject {
            Species::ListingsExportFactory.new({
              :designation_id => eu.id,
              :species_listings_ids => [eu_A.id],
              :geo_entities_ids => [nepal.id]
            })
          }
          specify { expect(subject.query.to_a.size).to eq(1) }
        end
      end
      context "when higher taxon ids" do
        subject {
          Species::ListingsExportFactory.new({
            :designation_id => eu.id,
            :taxon_concepts_ids => [@family.id]
          })
        }
        specify { expect(subject.query.to_a.size).to eq(1) }
      end
    end
  end
end
