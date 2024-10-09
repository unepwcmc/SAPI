require 'spec_helper'

describe Admin::TaxonConceptCommentsController do
  login_admin

  before do
    @taxon_concept = create(:taxon_concept)
  end

  describe 'GET index' do
    it 'renders the index template' do
      get :index, params: { taxon_concept_id: @taxon_concept.id }
      expect(response).to render_template('index')
    end
  end

  describe 'POST create' do
    it 'redirects to index with notice when success' do
      post :create, params: { taxon_concept_id: @taxon_concept.id, comment: { note: 'blah' } }
      expect(response).to redirect_to(
        admin_taxon_concept_comments_url(@taxon_concept)
      )
      expect(flash[:notice]).not_to be_nil
    end
  end

  describe 'PUT update' do
    let(:comment) { @taxon_concept.comments.create({ note: 'bleh' }) }
    it 'redirects to index with notice when success' do
      put :update, params: { id: comment.id, taxon_concept_id: @taxon_concept.id, comment: { note: 'blah' } }
      expect(response).to redirect_to(
        admin_taxon_concept_comments_url(@taxon_concept)
      )
      expect(flash[:notice]).not_to be_nil
    end
  end
end
