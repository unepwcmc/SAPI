require 'spec_helper'

describe Api::V1::DocumentGeoEntitiesController do
  context "when searching by taxon concept name" do
    include_context "Canis lupus"
    let!(:document_about_wolf_in_poland) {
      d = create(:document)
      c = create(:document_citation, document: d)
      create(:document_citation_taxon_concept, taxon_concept_id: @species.id, document_citation: c)
      create(:document_citation_geo_entity, geo_entity: poland, document_citation: c)
      d
    }
    let!(:document_not_about_wolf_not_in_poland) {
      d = create(:document)
      c = create(:document_citation, document: d)
      create(:document_citation_geo_entity, geo_entity: nepal, document_citation: c)
      d
    }
    let!(:document_not_about_wolf_in_poland) {
      d = create(:document)
      c = create(:document_citation, document: d)
      create(:document_citation_geo_entity, geo_entity: poland, document_citation: c)
      d
    }

    it "returns Poland when searching by wolf" do
      get :index, taxon_concept_query: 'Canis lu'
      response.body.should have_json_size(1).at_path('document_geo_entities')
    end

    it "returns 0 geo entities when no match for taxon name" do
      get :index, taxon_concept_query: 'Lynx'
      response.body.should have_json_size(0).at_path('document_geo_entities')
    end

    it "returns all geo entities when no taxon name given" do
      get :index
      response.body.should have_json_size(7).at_path('document_geo_entities')
    end

  end

end
