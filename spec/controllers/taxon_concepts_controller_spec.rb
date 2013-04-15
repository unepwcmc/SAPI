require 'spec_helper'
describe TaxonConceptsController do
  describe "XHR GET JSON autocomplete" do
    include_context "Arctocephalus"
    context "when searching by accepted name" do
      it "returns 1 result" do
        xhr :get, :autocomplete, :format => 'json',
          :scientific_name => 'Arctocephalus townsendi'
        response.body.should have_json_size(1)
        parse_json(response.body, "0/full_name").should == 'Arctocephalus townsendi' 
      end
    end
    context "when searching by common name" do
      it "returns 1 result" do
        xhr :get, :autocomplete, :format => 'json',
          :scientific_name => 'Guadalupe Fur Seal'
        response.body.should have_json_size(1)
        parse_json(response.body, "0/full_name").should == 'Arctocephalus townsendi' 
      end
    end
  end
end
