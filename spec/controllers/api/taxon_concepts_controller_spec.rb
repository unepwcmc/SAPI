require 'spec_helper'

describe Api::V1::TaxonConceptsController, type: :controller do
  context "GET index" do
    it " logs with Ahoy with different parameters" do
      expect {
        get :index, params: { taxonomy: 'cites_eu', taxon_concept_query: 'stork', geo_entity_scope: 'cites', page: 1 }
      }.to change { Ahoy::Event.count }.by(1)
      expect(Ahoy::Event.last.visit_id).to_not be(nil)

      expect {
        get :index, params: { taxonomy: 'cites_eu', taxon_concept_query: 'dolphin', geo_entity_scope: 'cites', page: 1 }
      }.to change { Ahoy::Event.count }.by(1)
      expect(@ahoy_event1).to eq(@ahoy_event2)
    end
  end

  context "GET show" do
    context "Minimal taxon" do
      let!(:taxon_concept) {
        create(:taxon_concept)
      }
      let!(:m_taxon_concept) {
        taxon_concept.m_taxon_concept
      }

      it "Serialises a minimal taxon correctly" do
        get :show, params: { id: taxon_concept.id }

        response_body = parse_json(response.body)

        # Make sure we have the correct taxon
        expect(
          response_body['taxon_concept']['full_name']
        ).to eq(
          taxon_concept.full_name
        )

        # We expect the response to be a superset of the following:
        expected = {
          "id"=>taxon_concept.id,
          "parent_id"=>taxon_concept.parent_id,
          "full_name"=>taxon_concept.full_name,
          "author_year"=>nil,
          "standard_references"=>[],
          "common_names"=>[],
          "distributions"=>[],
          "subspecies"=>[],
          "distribution_references"=>[],
          "name_status"=>"A",
          "nomenclature_note_en"=>nil,
          "nomenclature_notification"=>false,
          "cites_listing"=>nil,
          "eu_listing"=>nil,
          "accepted_names"=>[],
          "synonyms"=>[],
          "references"=>[],
          "cites_quotas"=>[],
          "cites_suspensions"=>[],
          "cites_listings"=>[],
          "eu_listings"=>[],
          "eu_decisions"=>[],
          "cites_processes"=>[]
        }

        expect(
          response_body['taxon_concept'].slice(*(expected.keys))
        ).to eq(expected)
      end
    end

    context "Taxon with CITES Processes" do
      let!(:taxon_concept) {
        create(
          :taxon_concept,
        )
      }

      let!(:cites_rst_process) {
        create(
          :cites_rst_process,
          taxon_concept: taxon_concept
        )
      }

      it "Serialises a minimal taxon correctly" do
        get :show, params: { id: taxon_concept.id }

        response_body = parse_json(response.body)

        # Make sure we have the correct taxon
        expect(
          response_body['taxon_concept']['full_name']
        ).to eq(
          taxon_concept.full_name
        )

        # Check that CITES RST processes are included in the response
        expect(
          response_body['taxon_concept']['cites_processes'].length
        ).to eq(
          1
        )
      end
    end
  end
end
