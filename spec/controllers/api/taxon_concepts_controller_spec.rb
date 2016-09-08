require 'spec_helper'

describe Api::V1::TaxonConceptsController, :type => :controller do
  context "GET index" do
    it " logs with Ahoy with different parameters" do
      expect {
        get :index, {
          :taxonomy => 'cites_eu',
          :taxon_concept_query => 'stork',
          :geo_entity_scope => 'cites',
          :page => 1
        }
      }.to change { Ahoy::Event.count }.by(1)
      expect(Ahoy::Event.last.visit_id).to_not be(nil)

      expect {
        get :index, {
          :taxonomy => 'cites_eu',
          :taxon_concept_query => 'dolphin',
          :geo_entity_scope => 'cites',
          :page => 1
        }
      }.to change { Ahoy::Event.count }.by(1)
      expect(@ahoy_event1).to eq(@ahoy_event2)
    end
  end
end
