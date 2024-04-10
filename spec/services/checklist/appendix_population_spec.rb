require 'spec_helper'

describe Checklist do
  include_context "Canis lupus"

  context "search by cites populations" do
    before(:each) { SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings }
    context "when Nepal" do
      subject {
        checklist = Checklist::Checklist.new({
          :country_ids => [nepal.id]
        })
        checklist.results
      }
      specify do
        expect(subject).to include(@species)
      end
    end
    context "when Poland" do
      subject {
        checklist = Checklist::Checklist.new({
          :country_ids => [poland.id]
        })
        checklist.results
      }
      specify do
        expect(subject).to include(@species)
      end
    end
  end
  context "search by cites appendices" do
    before(:each) { SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings }
    context "when App I" do
      subject {
        checklist = Checklist::Checklist.new({
          :cites_appendices => ['I']
        })
        checklist.results
      }
      specify do
        expect(subject).to include(@species)
      end
    end
    context "when App II" do
      subject {
        checklist = Checklist::Checklist.new({
          :cites_appendices => ['II']
        })
        checklist.results
      }
      specify do
        expect(subject).to include(@species)
      end
    end
    context "when App III" do
      subject {
        checklist = Checklist::Checklist.new({
          :cites_appendices => ['III']
        })
        checklist.results
      }
      specify do
        expect(subject).not_to include(@species)
      end
    end
  end
  context "search by cites populations and appendices" do
    before(:each) { SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings }
    context "when Nepal" do
      context "when App I" do
        subject {
          checklist = Checklist::Checklist.new({
            :cites_appendices => ['I'],
            :country_ids => [nepal.id]
          })
          checklist.results
        }
        specify do
          expect(subject).to include(@species)
        end
      end
      context "when App II" do
        subject {
          checklist = Checklist::Checklist.new({
            :cites_appendices => ['II'],
            :country_ids => [nepal.id]
          })
          checklist.results
        }
        specify do
          expect(subject).not_to include(@species)
        end
      end
    end
    context "when Poland" do
      context "when App I" do
        subject {
          checklist = Checklist::Checklist.new({
            :cites_appendices => ['I'],
            :country_ids => [poland.id]
          })
          checklist.results
        }
        specify do
          expect(subject).not_to include(@species)
        end
      end
      context "when App II" do
        subject {
          checklist = Checklist::Checklist.new({
            :cites_appendices => ['II'],
            :country_ids => [poland.id]
          })
          checklist.results
        }
        specify do
          expect(subject).to include(@species)
        end
      end
    end
    context "when Poland or Nepal" do
      context "when App I" do
        subject {
          checklist = Checklist::Checklist.new({
            :cites_appendices => ['I'],
            :country_ids => [poland.id, nepal.id]
          })
          checklist.results
        }
        specify do
          expect(subject).to include(@species)
        end
      end
      context "when App II" do
        subject {
          checklist = Checklist::Checklist.new({
            :cites_appendices => ['II'],
            :country_ids => [poland.id, nepal.id]
          })
          checklist.results
        }
        specify do
          expect(subject).to include(@species)
        end
      end
    end
    context "when App I or II" do
      context "when Poland" do
        subject {
          checklist = Checklist::Checklist.new({
            :cites_appendices => ['I', 'II'],
            :country_ids => [poland.id]
          })
          checklist.results
        }
        specify do
          expect(subject).to include(@species)
        end
      end
      context "when Nepal" do
        subject {
          checklist = Checklist::Checklist.new({
            :cites_appendices => ['I', 'II'],
            :country_ids => [nepal.id]
          })
          checklist.results
        }
        specify do
          expect(subject).to include(@species)
        end
      end
    end
  end
end
