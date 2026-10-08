require 'spec_helper'

# A view spec rather than render_views on the controller: the admin layout
# compiles assets, which would make these the only examples in the suite that
# need node installed. What the controller assigns is covered by its own spec.
describe 'admin/taxon_mappings/index' do
  let(:import_run) { create(:import_run) }
  let(:cites) { MatchableTaxonomy.create!(code: 'CITES_EU', name: 'CITES / EU') }
  let(:iucn) { MatchableTaxonomy.create!(code: 'IUCNRL', name: 'IUCN Red List') }

  def import_row(**attributes)
    ImportRun.new(kind: 'mapping_taxa', importable: cites, **attributes).tap do |import|
      import.file.attach(
        io: StringIO.new("Status,Id\nA,1\n"), filename: 'cites_eu.csv', content_type: 'text/csv'
      )
      import.save!
    end
  end

  def draw(
    taxonomy_rows: [
      {
        taxonomy: cites, names: 2, accepted: 1, import_run: import_run,
        loaded_at: Time.current
      }
    ],
    pair_rows: [ { near: cites, far: iucn } ],
    unresolved_rows: [],
    imports: []
  )
    assign(:taxonomy_rows, taxonomy_rows)
    assign(:pair_rows, pair_rows)
    assign(:unresolved_rows, unresolved_rows)
    assign(:taxonomy_options, [ [ cites.code, cites.id ], [ iucn.code, iucn.id ] ])
    # The template paginates, so a bare array is not enough.
    assign(:imports, Kaminari.paginate_array(imports).page(1).per(10))
    assign(:running_imports, imports.any? { |i| i.pending? || i.running? })
    render
  end

  it 'offers the upload form' do
    draw

    expect(rendered).to have_css 'form#taxon-mapping-upload'
  end

  it 'sends the file straight to storage, not through a Rails worker' do
    # The largest export is around 200 MB. Without this it travels through the
    # app and whatever body limit sits in front of it.
    draw

    expect(rendered).to have_css 'input[type=file][data-direct-upload-url]'
  end

  it "leaves the timestamp for the browser to put in the reader's own zone" do
    draw

    expect(rendered).to have_css 'time[data-local-time][datetime]'
  end

  it 'says a taxonomy holding nothing is not loaded, rather than showing zero' do
    draw(taxonomy_rows: [ { taxonomy: iucn } ])

    expect(rendered).to include 'not loaded'
  end

  describe 'the match pairs table' do
    def pair_rows(loaded:, empty:)
      Array.new(loaded) { {
        near: cites, far: iucn, matches: 5, import_run: import_run,
        loaded_at: Time.current
      } } +
        Array.new(empty) { { near: cites, far: iucn } }
    end

    it 'hides the pairs holding nothing, so the loaded ones are not buried' do
      draw(pair_rows: pair_rows(loaded: 1, empty: 2))

      expect(rendered)
        .to have_css 'tr.js-empty-pair[style*="display: none"]', count: 2, visible: :all
    end

    it 'still renders them, since a blank row is what shows an upload is missing' do
      draw(pair_rows: pair_rows(loaded: 1, empty: 2))

      expect(rendered).to have_css 'tr.js-empty-pair', count: 2, visible: :all
    end

    it 'offers a way to see them, saying how many there are' do
      draw(pair_rows: pair_rows(loaded: 1, empty: 2))

      expect(rendered).to have_css '.js-toggle-empty-pairs', text: '2 pairs'
    end

    it 'leaves the loaded ones alone' do
      draw(pair_rows: pair_rows(loaded: 1, empty: 2))

      expect(rendered)
        .to have_no_css 'tr[style*="display: none"] td', text: '5', visible: :all
    end

    it 'offers no button when every pair holds something' do
      draw(pair_rows: pair_rows(loaded: 2, empty: 0))

      expect(rendered).to have_no_css '.js-toggle-empty-pairs'
    end

    it 'hides them even when nothing at all is loaded' do
      # The heading still says 0 of 2, so the table being empty is not a
      # mystery - and the button is there to open it.
      draw(pair_rows: pair_rows(loaded: 0, empty: 2))

      expect(rendered).to have_css 'tr.js-empty-pair[style*="display: none"]', count: 2, visible: :all
    end

    it 'offers the button when nothing at all is loaded' do
      draw(pair_rows: pair_rows(loaded: 0, empty: 2))

      expect(rendered).to have_css '.js-toggle-empty-pairs', text: '2 pairs'
    end
  end

  it 'collapses the unresolved block to a line when there is nothing to report' do
    draw

    expect(rendered).to have_no_css 'th', text: 'Side'
  end

  it 'links a count to the matches behind it, so the number can be acted on' do
    draw(
      unresolved_rows: [
        {
          taxonomy: cites, unresolved: 111, taxa_loaded: true, side: :near,
          import_run_id: import_run.id, import_run: import_run
        }
      ]
    )

    expect(rendered).to have_css "a[href*='unresolved_matches']", text: '111'
  end

  it 'opens the run behind a timestamp, rather than crowding the table with it' do
    draw

    expect(rendered).to have_css "a[href*='import_runs'][data-remote='true']"
  end

  it 'has somewhere for the run to be rendered into' do
    # The id has to match what import_runs/show.js.erb fills, and a mismatch is
    # silent: the modal opens empty.
    draw

    expect(rendered).to have_css '#import-run .modal-body#admin-import-run', visible: :all
  end

  it 'offers nothing to save, since the run is only being read' do
    draw

    expect(rendered).to have_no_css '#import-run .save-button', visible: :all
  end

  it 'leaves the file name out of the tables, since the run carries it' do
    draw

    expect(rendered).to have_no_css 'th', text: 'Source file'
  end

  it 'names the file behind an unresolved reference, looked up through the run' do
    draw(
      unresolved_rows: [
        {
          taxonomy: cites, unresolved: 119, taxa_loaded: true, side: :near,
          import_run_id: import_run.id, import_run: import_run
        }
      ]
    )

    expect(rendered).to include import_run.filename
  end

  it 'says nothing has been uploaded yet when nothing has' do
    draw

    expect(rendered).to include 'Nothing has been uploaded yet'
  end

  it 'names the taxonomy an upload was aimed at' do
    draw(imports: [ import_row(status: ImportRun::DONE) ])

    expect(rendered).to include 'CITES_EU'
  end

  it 'takes the row count from the logs, since no column holds it' do
    draw(
      imports: [
        import_row(
          status: ImportRun::DONE,
          logs: [
            { 'level' => 'info', 'message' => 'import completed', 'written' => 18_186 },
            { 'level' => 'info', 'message' => 'rows retained', 'retained' => 12_675 }
          ]
        )
      ]
    )

    # What survived the collapse, not what the importer wrote.
    expect(rendered).to include '12,675'
  end

  it 'opens a failed upload on the problems that caused it' do
    failed = import_row(
      status: ImportRun::FAILED,
      logs: [
        {
          'level' => 'error', 'row' => 4812, 'column' => 'Status',
          'message' => 'blank, and the column is not nullable'
        }
      ]
    )

    draw(imports: [ failed ])

    expect(rendered).to include 'blank, and the column is not nullable'
  end

  it 'leaves a successful upload with nothing to open' do
    done = import_row(
      status: ImportRun::DONE,
      logs: [ { 'level' => 'info', 'message' => 'import completed', 'written' => 2 } ]
    )

    draw(imports: [ done ])

    expect(rendered).not_to include 'import completed'
  end
end
