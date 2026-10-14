require 'spec_helper'

describe Admin::TaxonMappings::ImportRunsController do
  render_views

  let!(:cites) { MatchableTaxonomy.create!(code: 'CITES', name: 'CITES') }
  # Stubbed on the storage service, which is a singleton: the Disk service used
  # in test cannot build a URL without ActiveStorage::Current.url_options, and
  # the middleware that would set them from the request never runs in a
  # controller spec. What matters here is that the action hands out a URL
  # rather than the file itself.
  let(:service_url) { 'https://example.test/cites.csv?X-Amz-Expires=60' }

  def run(status: ImportRun::DONE, **attributes)
    ImportRun.new(kind: 'mapping_taxa', importable: cites, status: status, **attributes).tap do |r|
      r.file.attach(
        io: StringIO.new("Status,Id\nA,1\n"), filename: 'cites.csv', content_type: 'text/csv'
      )
      r.save!
    end
  end


  before { allow(ActiveStorage::Blob.service).to receive(:url).and_return(service_url) }

  def show(record)
    get :show, params: { id: record.id }, format: :js, xhr: true
  end

  describe 'as a manager' do
    login_admin

    it 'opens the run the timestamp belonged to' do
      record = run

      show(record)
      expect(assigns(:import_run)).to eq record
    end

    it 'names the file it loaded' do
      show(run)
      expect(response.body).to include 'cites.csv'
    end

    it 'offers the file itself, which is the point of keeping it' do
      show(run)
      expect(response.body).to include 'Download'
    end

    describe 'downloading it' do
      it 'hands out a URL rather than the bytes' do
        get :download, params: { id: run.id }

        expect(response).to redirect_to service_url
      end

      it 'does not link straight at the blob, which would never expire' do
        # rails_blob_path signs a permanent URL and asks nobody for
        # credentials; the same warning is on the three document controllers.
        show(run)

        expect(response.body).not_to include 'rails/active_storage'
      end

      it 'says so when there is no file to hand out' do
        record = run
        record.file.purge

        get :download, params: { id: record.id }
        expect(response).to have_http_status :not_found
      end
    end

    it 'says what it loaded into' do
      show(run)
      expect(response.body).to include 'CITES'
    end

    it 'shows what stopped a run that failed' do
      failed = run(
        status: ImportRun::FAILED,
        logs: [
          {
            'level' => 'error', 'row' => 4812, 'column' => 'Status',
            'message' => 'blank, and the column is not nullable'
          }
        ]
      )

      show(failed)
      expect(response.body).to include 'blank, and the column is not nullable'
    end

    it 'refuses a run belonging to another feature' do
      # The page only ever links to its own, so an id from elsewhere is either a
      # mistake or someone poking at the URL.
      stub_const('ImportRun::JOBS', ImportRun::JOBS.merge('elsewhere' => 'Imports::MappingTaxaJob'))
      other = run
      # Past validation: the kind whitelist is read when the class loads, so a
      # kind that exists only inside this example cannot pass it.
      other.kind = 'elsewhere'
      other.save!(validate: false)

      expect { show(other) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'as a contributor' do
    login_contributor

    it 'is refused' do
      # ApplicationController answers a denied .js request by telling the page
      # to reload, which is a 200 - so what matters is that none of the run
      # reaches them.
      show(run)

      expect(response.body).not_to include 'cites.csv'
    end

    it 'cannot download it either' do
      get :download, params: { id: run.id }

      expect(response).to be_redirect
    end

    it 'does not even load it' do
      show(run)

      expect(assigns(:import_run)).to be_nil
    end
  end
end
