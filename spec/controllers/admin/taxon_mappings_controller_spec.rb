require 'spec_helper'

describe Admin::TaxonMappingsController do
  let(:import_run) { create(:import_run) }
  let!(:cites) { MatchableTaxonomy.create!(code: 'CITES_EU', name: 'CITES / EU') }
  let!(:iucn) { MatchableTaxonomy.create!(code: 'IUCNRL', name: 'IUCN Red List') }

  def taxon(taxonomy, nid, status = 'A')
    MappingTaxon.create!(
      matchable_taxonomy: taxonomy, taxon_nid: nid, accepted_taxon_nid: nid,
      name_status: status, scientific_name: 'Panthera leo', import_run: import_run
    )
  end

  def match
    MappingMatch.create!(
      matchable_taxonomy: cites, taxon_nid: '1',
      foreign_matchable_taxonomy: iucn, foreign_taxon_nid: '9',
      matched_name: 'n', matched_name_status: 'A',
      foreign_matched_name: 'n', foreign_matched_name_status: 'A',
      match_confidence: 'high', import_run: import_run
    )
  end

  def import_row(kind: 'mapping_taxa', validate: true)
    ImportRun.new(kind: kind, importable: cites).tap do |import|
      import.file.attach(
        io: StringIO.new("Status,Id\nA,1\n"), filename: 'cites_eu.csv', content_type: 'text/csv'
      )
      import.save!(validate: validate)
    end
  end

  describe 'GET index' do
    context 'when signed in as a manager' do
      login_admin

      it 'lists every platform, including the ones holding nothing' do
        taxon(cites, '1')

        get :index
        expect(assigns(:taxonomy_rows).pluck(:taxonomy)).to eq [ cites, iucn ]
      end

      it 'leaves a platform holding nothing without counts, rather than showing zero' do
        get :index
        expect(assigns(:taxonomy_rows).first).not_to have_key :names
      end

      it 'lists every possible pair, loaded or not' do
        # Two platforms make one pair; the point is that it appears before
        # anything has been uploaded for it.
        get :index
        expect(assigns(:pair_rows).size).to eq 1
      end

      it 'reports a match whose taxon is not held' do
        match
        taxon(iucn, '9')

        get :index
        expect(assigns(:unresolved_rows))
          .to contain_exactly(hash_including(taxonomy: cites, unresolved: 1))
      end

      it 'flags a platform whose taxa were never uploaded, rather than blaming the file' do
        match

        get :index
        expect(assigns(:unresolved_rows)).to all(include(taxa_loaded: false))
      end

      it 'shows the last few uploads, newest first' do
        older = import_row
        newer = import_row

        get :index
        expect(assigns(:imports).first(2)).to eq [ newer, older ]
      end

      it 'leaves other features\' uploads alone, since the table is shared' do
        mine = import_row
        # Written past validation: the kind whitelist is read when the class
        # loads, so a kind that only exists inside this example cannot pass it.
        stub_const('ImportRun::JOBS', ImportRun::JOBS.merge('elsewhere' => 'Imports::MappingTaxaJob'))
        import_row(kind: 'elsewhere', validate: false)

        get :index
        expect(assigns(:imports)).to eq [ mine ]
      end

      it 'shows no more than a page at a time' do
        (TaxonMappingImports::PER_PAGE + 1).times { import_row }

        get :index
        expect(assigns(:imports).size).to eq TaxonMappingImports::PER_PAGE
      end

      it 'has the rest on the next page' do
        (TaxonMappingImports::PER_PAGE + 1).times { import_row }

        get :index, params: { page: 2 }
        expect(assigns(:imports).size).to eq 1
      end

      it 'notices an upload that has not finished, so the page can come back for it' do
        import_row

        get :index
        expect(assigns(:running_imports)).to be true
      end

      it 'leaves the page alone once every upload has finished' do
        import_row.update!(status: ImportRun::DONE)

        get :index
        expect(assigns(:running_imports)).to be false
      end

      it 'says nothing is unresolved once both sides are held' do
        match
        taxon(cites, '1')
        taxon(iucn, '9')

        get :index
        expect(assigns(:unresolved_rows)).to be_empty
      end
    end

    context 'when signed in as a contributor' do
      login_contributor

      it 'is refused' do
        # The menu entry is hidden from them, but hiding is not access control.
        get :index
        expect(response).to be_redirect
      end
    end
  end
end
