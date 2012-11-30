require 'spec_helper'

describe MTaxonConcept do
  include_context "Canis lupus"
  context "search by cites populations" do
    context "when Nepal" do
      specify do
        MTaxonConcept.by_cites_populations_and_appendices([], [nepal.id]).
        should include(@species)
      end
    end
    context "when Poland" do
      specify do
        MTaxonConcept.by_cites_populations_and_appendices([], [poland.id]).
        should include(@species)
      end
    end
  end
  context "search by cites appendices" do
    context "when App I" do
      specify do
        MTaxonConcept.by_cites_appendices(['I']).should include(@species)
      end
    end
    context "when App II" do
      specify do
        MTaxonConcept.by_cites_appendices(['II']).should include(@species)
      end
    end
    context "when App III" do
      specify do
        MTaxonConcept.by_cites_appendices(['III']).should_not include(@species)
      end
    end
  end
  context "search by cites populations and appendices" do
    context "when Nepal" do
      context "when App I" do
        specify do
          MTaxonConcept.
          by_cites_populations_and_appendices([], [nepal.id], ['I']).
          should include(@species)
        end
      end
      context "when App II" do
        specify do
          puts MTaxonConcept.
          by_cites_populations_and_appendices([], [nepal.id], ['II']).to_sql
          MTaxonConcept.
          by_cites_populations_and_appendices([], [nepal.id], ['II']).
          should_not include(@species)
        end
      end
    end
    context "when Poland" do
      context "when App I" do
        specify do
          MTaxonConcept.
          by_cites_populations_and_appendices([], [poland.id], ['I']).
          should_not include(@species)
        end
      end
      context "when App II" do
        specify do

          MTaxonConcept.
          by_cites_populations_and_appendices([], [poland.id], ['II']).
          should include(@species)
        end
      end
    end
    context "when Poland or Nepal" do
      context "when App I" do
        specify do
          MTaxonConcept.
          by_cites_populations_and_appendices([], [poland.id, nepal.id], ['I']).
          should include(@species)
        end
      end
      context "when App II" do
        specify do
puts MTaxonConcept.
          by_cites_populations_and_appendices([], [poland.id, nepal.id], ['II']).to_sql
          MTaxonConcept.
          by_cites_populations_and_appendices([], [poland.id, nepal.id], ['II']).
          should include(@species)
        end
      end
    end
    context "when App I or II" do
      context "when Poland" do
        specify do
          MTaxonConcept.
          by_cites_populations_and_appendices([], [poland.id], ['I', 'II']).
          should include(@species)
        end
      end
      context "when Nepal" do
        specify do

          MTaxonConcept.
          by_cites_populations_and_appendices([], [nepal.id], ['I', 'II']).
          should include(@species)
        end
      end
    end
  end
end
