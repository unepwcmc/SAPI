require 'spec_helper'

describe Admin::TaxonMappings::ImportsController do
  render_views

  let!(:cites) { MatchableTaxonomy.create!(code: 'CITES', name: 'CITES') }

  def import_row(status: Import::RUNNING, filename: 'cites.csv')
    Import.new(kind: 'mapping_taxa', importable: cites, status: status).tap do |import|
      import.file.attach(
        io: StringIO.new("Status,Id\nA,1\n"), filename: filename, content_type: 'text/csv'
      )
      import.save!
    end
  end

  describe 'as a manager' do
    login_admin

    it 'renders the block on its own, with no page around it' do
      import_row

      get :index
      expect(response.body).not_to include '<html'
    end

    it 'says an import is still working, which is what the poll reads' do
      import_row(status: Import::RUNNING)

      get :index
      expect(response.body).to include 'data-running="true"'
    end

    it 'says so when the last one has finished, so the poll can stop' do
      import_row(status: Import::DONE)

      get :index
      expect(response.body).to include 'data-running="false"'
    end

    it 'shows the imports themselves' do
      import_row(filename: 'iucn.csv')

      get :index
      expect(response.body).to include 'iucn.csv'
    end

    it 'leaves another feature uploads out, as the page does' do
      stub_const('Import::JOBS', Import::JOBS.merge('elsewhere' => 'Imports::MappingTaxaJob'))
      Import.new(kind: 'elsewhere', importable: cites).tap do |import|
        import.file.attach(
          io: StringIO.new('x'), filename: 'not-ours.csv', content_type: 'text/csv'
        )
        import.save!(validate: false)
      end

      get :index
      expect(response.body).not_to include 'not-ours.csv'
    end

    it 'keeps the pagination links pointing at the page, not at itself' do
      # Rendered from here, Kaminari would otherwise build links back to this
      # endpoint and paginate the reader into a bare fragment.
      (TaxonMappingImports::PER_PAGE + 1).times { import_row }

      get :index
      expect(response.body).to include 'taxon_mappings?page=2'
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
