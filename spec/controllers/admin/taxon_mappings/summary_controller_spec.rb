require 'spec_helper'

describe Admin::TaxonMappings::SummaryController do
  render_views

  let!(:cites) { MatchableTaxonomy.create!(code: 'CITES', name: 'CITES') }

  # Two taxonomies make one pair, which is what the pairs table has to list.
  before { MatchableTaxonomy.create!(code: 'IUCN', name: 'IUCN Red List') }

  def import_run = @import_run ||= create(:import_run)

  def taxon(taxonomy, nid)
    MappingTaxon.create!(
      matchable_taxonomy: taxonomy, taxon_nid: nid, accepted_taxon_nid: nid,
      name_status: 'A', scientific_name: 'Panthera leo', import_run: import_run
    )
  end

  describe 'as a manager' do
    login_admin

    it 'renders the blocks on their own, with no page around them' do
      get :show
      expect(response.body).not_to include '<html'
    end

    it 'counts what each taxonomy holds' do
      taxon(cites, '1')

      get :show
      expect(response.body).to include 'CITES'
    end

    it 'opens the run a taxonomy was loaded by, rather than naming the file here' do
      taxon(cites, '1')

      get :show
      expect(response.body).to include admin_taxon_mappings_import_run_path(import_run)
    end

    it 'lists every pair, loaded or not' do
      get :show
      expect(response.body).to include 'not loaded'
    end

    it 'carries where to ask again, so one fetch can replace it' do
      get :show
      expect(response.body).to include 'data-refresh-url'
    end
  end

  describe 'as a contributor' do
    login_contributor

    it 'is refused' do
      get :show
      expect(response).to be_redirect
    end
  end
end
