require 'spec_helper'

describe Api::V1::AutoCompleteTaxonConceptsController do
  include_context "Boa constrictor"

  describe "GET index" do
    it "returns 1 result when searching for species name and filtering for rank SPECIES" do
      get :index, :taxonomy => "CITES",
        :taxon_concept_query => "Boa", :ranks => ["SPECIES"],
        :visibility => "trade"
      response.body.should have_json_size(1).
        at_path("auto_complete_taxon_concepts")
    end
    it "returns 3 results when searching for species name and not filtering by rank" do
      get :index, :taxonomy => "CITES",
        :taxon_concept_query => "Boa"
      response.body.should have_json_size(3).
        at_path("auto_complete_taxon_concepts")
    end
  end
end
