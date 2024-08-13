require 'spec_helper'

describe Admin::TaxonRelationshipsController do
  login_admin

  before(:each) { equal_relationship_type }
  let(:taxon_concept) { create(:taxon_concept) }
  describe 'GET index' do
    let(:taxon_relationship) do
      create(:taxon_relationship, taxon_concept_id: taxon_concept.id)
    end
    it 'assigns @taxon_relationships' do
      get :index, params: { taxon_concept_id: taxon_concept.id, type: taxon_relationship.taxon_relationship_type.name }
      expect(assigns(:taxon_relationships)).to eq([ taxon_relationship ])
      assigns(:taxon_concept)
    end
    it 'renders the index template' do
      get :index, params: { taxon_concept_id: taxon_concept.id }
      expect(response).to render_template('index')
    end
    it 'renders the taxon_concepts_layout' do
      get :index, params: { taxon_concept_id: taxon_concept.id }
      expect(response).to render_template('layouts/taxon_concepts')
    end
  end

  describe 'XHR POST create' do
    let(:taxon_relationship_attributes) { build_attributes(:taxon_relationship) }
    before do
      allow(TaxonRelationshipType).to receive(:find).and_return(equal_relationship_type)
    end
    it 'renders create when successful' do
      post :create, params: {
        taxon_relationship: taxon_relationship_attributes,
        taxon_concept_id: taxon_concept.id
      }, xhr: true
      expect(response).to render_template('create')
    end
    it 'renders new when not successful' do
      taxon_relationship = create(:taxon_relationship, taxon_relationship_attributes)
      post :create, params: {
        taxon_relationship: taxon_relationship_attributes,
        taxon_concept_id: taxon_relationship.taxon_concept_id
      }, xhr: true
      expect(response).to render_template('new')
    end
  end

  describe 'DELETE destroy' do
    context 'when relationship is bidirectional' do
      let(:taxon_concept) do
        create_cites_eu_species
      end
      let(:other_taxon_concept) do
        create_cms_species
      end
      let!(:rel) do
        create(
          :taxon_relationship,
          taxon_relationship_type: equal_relationship_type,
          taxon_concept_id: taxon_concept.id,
          other_taxon_concept_id: other_taxon_concept.id
        )
      end
      context 'destroys relationship for taxon concept' do
        specify do
          expect do
            delete :destroy, params: { taxon_concept_id: taxon_concept.id, id: rel.id }
          end.to change(TaxonRelationship, :count).by(-2)
        end
      end
      context 'destroys relationship for other taxon concept' do
        specify do
          expect do
            delete :destroy, params: { taxon_concept_id: other_taxon_concept.id, id: rel.id }
          end.to change(TaxonRelationship, :count).by(-2)
        end
      end
    end
    context 'when relationship is not bidirectional' do
      let(:taxon_concept) do
        create_cites_eu_species
      end
      let(:other_taxon_concept) do
        create_cites_eu_species(name_status: 'S')
      end
      let!(:rel) do
        create(
          :taxon_relationship,
          taxon_relationship_type: synonym_relationship_type,
          taxon_concept_id: taxon_concept.id,
          other_taxon_concept_id: other_taxon_concept.id
        )
      end
      context 'destroys relationship for taxon concept' do
        specify do
          expect do
            delete :destroy, params: { taxon_concept_id: taxon_concept.id, id: rel.id }
          end.to change(TaxonRelationship, :count).by(-1)
        end
      end
      context 'destroys relationship for other taxon concept' do
        specify do
          expect do
            delete :destroy, params: { taxon_concept_id: other_taxon_concept.id, id: rel.id }
          end.to change(TaxonRelationship, :count).by(-1)
        end
      end
    end
  end
end
