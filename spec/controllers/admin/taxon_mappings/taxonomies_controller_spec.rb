require 'spec_helper'

describe Admin::TaxonMappings::TaxonomiesController do
  let(:import_run) { create(:import_run) }

  describe 'as a manager' do
    login_admin

    describe 'GET index' do
      it 'lists them by code' do
        MatchableTaxonomy.create!(code: 'IUCNRL', name: 'IUCN Red List')
        MatchableTaxonomy.create!(code: 'CITES_EU', name: 'CITES / EU')

        get :index
        expect(assigns(:taxonomies).map(&:code)).to eq %w[CITES_EU IUCNRL]
      end
    end

    describe 'POST create' do
      it 'adds one' do
        post :create, params: { taxonomy: { code: 'GARD', name: 'GARD' } }, format: :js

        expect(MatchableTaxonomy.find_by(code: 'GARD')).to be_present
      end

      it 'refuses a duplicate code' do
        MatchableTaxonomy.create!(code: 'GARD', name: 'GARD')

        post :create, params: { taxonomy: { code: 'GARD', name: 'Other' } }, format: :js

        expect(MatchableTaxonomy.where(code: 'GARD').count).to eq 1
      end
    end

    describe 'GET edit' do
      let!(:taxonomy) { MatchableTaxonomy.create!(code: 'GARD', name: 'GARD') }

      it 'opens the one asked for' do
        # xhr, because Rails refuses a plain GET that would return JavaScript -
        # which is what the remote link the pencil renders actually sends.
        get :edit, params: { id: taxonomy.id }, format: :js, xhr: true

        expect(assigns(:taxonomy)).to eq taxonomy
      end
    end

    describe 'PATCH update' do
      let!(:taxonomy) { MatchableTaxonomy.create!(code: 'GARD', name: 'GARD') }

      it 'renames it' do
        patch :update, params: { id: taxonomy.id, taxonomy: { name: 'Global Reptile Database' } },
          format: :js

        expect(taxonomy.reload.name).to eq 'Global Reptile Database'
      end

      it 'leaves the code alone, because the API is addressed by it' do
        patch :update, params: { id: taxonomy.id, taxonomy: { name: 'GARD', code: 'REPTILES' } },
          format: :js

        expect(taxonomy.reload.code).to eq 'GARD'
      end
    end

    describe 'DELETE destroy' do
      let(:taxonomy) { MatchableTaxonomy.create!(code: 'GARD', name: 'GARD') }

      it 'removes one nothing references' do
        delete :destroy, params: { id: taxonomy.id }

        expect(MatchableTaxonomy.exists?(taxonomy.id)).to be false
      end

      it 'refuses while it still holds names' do
        # They could only come back by re-uploading the file they came from.
        MappingTaxon.create!(
          matchable_taxonomy: taxonomy, taxon_nid: '1', accepted_taxon_nid: '1',
          name_status: 'A', scientific_name: 'Panthera leo', import_run: import_run
        )

        delete :destroy, params: { id: taxonomy.id }

        expect(MatchableTaxonomy.exists?(taxonomy.id)).to be true
      end

      it 'says what blocked it' do
        MappingTaxon.create!(
          matchable_taxonomy: taxonomy, taxon_nid: '1', accepted_taxon_nid: '1',
          name_status: 'A', scientific_name: 'Panthera leo', import_run: import_run
        )

        delete :destroy, params: { id: taxonomy.id }

        expect(flash[:alert]).to include 'taxon names'
      end
    end
  end

  describe 'as a contributor' do
    login_contributor

    it 'is refused' do
      get :index
      expect(response).to be_redirect
    end
  end
end
