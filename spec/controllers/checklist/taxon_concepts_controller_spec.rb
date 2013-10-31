require 'spec_helper'
describe Checklist::TaxonConceptsController do
  describe "XHR GET JSON autocomplete" do
    include_context "Arctocephalus"
    context "when searching by accepted name" do
      it "returns 1 result" do
        xhr :get, :autocomplete, :format => 'json',
          :scientific_name => 'Arctocephalus townsendi'
        response.body.should have_json_size(1)
      end
    end
    context "when query blank" do
      it "returns 0 results" do
        xhr :get, :autocomplete, :format => 'json'
        response.body.should have_json_size(0)
      end
    end
  end
end
