require 'spec_helper'

describe Admin::TaxonConceptCommentsController do
  login_admin

  before do
    @taxon_concept = create(:taxon_concept)
  end

  describe 'GET index' do
    it 'renders the index template' do
      get :index, taxon_concept_id: @taxon_concept.id
      response.should render_template('index')
    end
  end

  describe 'POST create' do
    it 'redirects to index with notice when success' do
      post :create,
        taxon_concept_id: @taxon_concept.id,
        comment: { note: 'blah' }
      response.should redirect_to(
        admin_taxon_concept_comments_url(@taxon_concept)
      )
      flash[:notice].should_not be_nil
    end
  end

  describe 'PUT update' do
    let(:comment) { @taxon_concept.comments.create({ note: 'bleh' }) }
    it 'redirects to index with notice when success' do
      put :update,
        id: comment.id,
        taxon_concept_id: @taxon_concept.id,
        comment: { note: 'blah' }
      response.should redirect_to(
        admin_taxon_concept_comments_url(@taxon_concept)
      )
      flash[:notice].should_not be_nil
    end
  end

end
