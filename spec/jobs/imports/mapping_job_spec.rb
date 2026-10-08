require 'spec_helper'
# caxlsx is require: false - it exists to build .xlsx fixtures, nothing else.
require 'axlsx'

# Imports::MappingJob is abstract, so its shared behaviour is exercised through
# the taxa subclass; the matches subclass only adds where the far side comes
# from, which is covered on its own below.
describe Imports::MappingJob do
  let(:cites) { MatchableTaxonomy.create!(code: 'CITES_EU', name: 'CITES / EU') }
  let(:iucn) { MatchableTaxonomy.create!(code: 'IUCNRL', name: 'IUCN Red List') }

  let(:taxa_csv) do
    "Status,Id,Id_Accepted,Rank,Scientific.Name,Author\n" \
      "A,1,1,SPECIES,Panthera leo,Linnaeus\nS,2,1,SPECIES,Felis leo,Schreber\n"
  end
  let(:matches_csv) do
    'd1_Id_Accepted,d1_Scientific.Name,d1_Status,' \
      "d2_Id_Accepted,d2_Scientific.Name,d2_Status,confidence_level,exclude\n" \
      "1,Panthera leo,A,9,Panthera leo,A,high,NA\n"
  end

  # The same rows the CSV above holds, as a real workbook.
  def xlsx(csv)
    rows = CSV.parse(csv)
    file = Tempfile.new([ 'upload', '.xlsx' ])
    file.close
    Axlsx::Package.new do |package|
      package.workbook.add_worksheet(name: 'Sheet1') do |sheet|
        rows.each { |row| sheet.add_row row }
      end
    end.serialize(file.path)
    File.binread(file.path)
  ensure
    file&.unlink
  end

  def zipped(members)
    file = Tempfile.new([ 'upload', '.zip' ])
    file.close
    File.unlink(file.path)
    Zip::File.open(file.path, create: true) do |zip|
      members.each { |name, contents| zip.get_output_stream(name) { |out| out.write(contents) } }
    end
    File.binread(file.path)
  ensure
    file&.unlink
  end

  def import!(
    kind: 'mapping_taxa', importable: cites, filename: 'cites_eu.csv', contents: taxa_csv,
    **attributes
  )
    ImportRun.new(kind: kind, importable: importable, **attributes).tap do |import|
      import.file.attach(
        io: StringIO.new(contents), filename: filename, content_type: 'application/octet-stream'
      )
      import.save!
    end
  end

  def run_taxa(**)
    import!(**).tap { |import| Imports::MappingTaxaJob.perform_now(import.id) }.reload
  end

  describe 'KINDS' do
    it 'names only kinds the imports table actually dispatches' do
      # ImportRun::JOBS is what decides which job a row is handed to; a kind listed
      # here and not there would show on the page and never run.
      expect(described_class::KINDS - ImportRun::JOBS.keys).to be_empty
    end

    it 'covers every job in this family' do
      expect(described_class::KINDS.map { |kind| ImportRun::JOBS.fetch(kind).constantize })
        .to all(be < described_class)
    end
  end

  describe 'a taxa upload' do
    it 'loads a bare CSV' do
      run_taxa

      expect(MappingTaxon.where(matchable_taxonomy: cites).count).to eq 2
    end

    it 'marks it done' do
      expect(run_taxa.status).to eq ImportRun::DONE
    end

    it 'keeps the importer logs, which is where the counts live' do
      expect(run_taxa.logs.last).to include('retained' => 2)
    end

    it 'times the run' do
      expect(run_taxa.duration).to be >= 0
    end

    it 'stamps every row with the run that wrote it' do
      # Not the file's name: two uploads can share one, and the path the file is
      # read from is an ActiveStorage tempfile. The run holds the file, so the
      # name is still reachable - and a whole upload can be found or removed.
      import = run_taxa(filename: 'cites_eu.csv')

      expect(MappingTaxon.distinct.pluck(:import_run_id)).to eq [ import.id ]
    end

    it 'unwraps a zip holding one CSV' do
      run_taxa(filename: 'taxonomies.zip', contents: zipped('cites_eu.csv' => taxa_csv))

      expect(MappingTaxon.count).to eq 2
    end

    it 'ignores the sidecars a zip made on a Mac carries' do
      contents = zipped(
        'cites_eu.csv' => taxa_csv,
        '__MACOSX/._cites_eu.csv' => 'junk',
        '.DS_Store' => 'junk'
      )

      expect(run_taxa(filename: 'taxonomies.zip', contents: contents).status).to eq ImportRun::DONE
    end

    it 'reads a spreadsheet rather than mistaking it for a zip' do
      # An .xlsx is itself a zip. Routing on the first four bytes would unwrap
      # it and report the parts of its OOXML package as files someone uploaded.
      import = import!(filename: 'cites_eu.xlsx', contents: xlsx(taxa_csv))

      Imports::MappingTaxaJob.perform_now(import.id)

      expect(import.reload.status).to eq ImportRun::DONE
    end

    it 'writes what the spreadsheet held' do
      import = import!(filename: 'cites_eu.xlsx', contents: xlsx(taxa_csv))

      Imports::MappingTaxaJob.perform_now(import.id)

      expect(MappingTaxon.where(matchable_taxonomy: cites).count).to eq 2
    end

    it 'refuses a zip holding a spreadsheet' do
      contents = zipped('cites_eu.xlsx' => xlsx(taxa_csv))
      import = run_taxa(filename: 'taxonomies.zip', contents: contents)

      expect(import).to have_attributes(status: ImportRun::FAILED)
      expect(import.logs.last['message']).to include 'must have one of these extensions'
    end

    it 'refuses a zip holding more than one file, saying so' do
      contents = zipped('one.csv' => taxa_csv, 'two.csv' => taxa_csv)
      import = run_taxa(filename: 'taxonomies.zip', contents: contents)

      expect(import).to have_attributes(status: ImportRun::FAILED)
      expect(import.logs.last['message']).to include 'found 2'
    end

    it 'marks a file the importer rejects as failed rather than raising' do
      expect(run_taxa(contents: "Nothing,Useful\n1,2\n").status).to eq ImportRun::FAILED
    end

    it 'says why the importer rejected it' do
      import = run_taxa(contents: "Nothing,Useful\n1,2\n")

      expect(import.logs.last['message']).to include 'Missing required headers'
    end
  end

  describe 'a row that is no longer pending' do
    it 'is left alone, so a retry does not replace the platform a second time' do
      import = run_taxa
      finished_at = import.finished_at

      Imports::MappingTaxaJob.perform_now(import.id)

      expect(import.reload.finished_at).to eq finished_at
    end
  end

  describe 'a matches upload' do
    def run_matches(**attributes)
      import = import!(
        kind: 'mapping_matches', contents: matches_csv,
        filename: 'match-results-cites-iucn.csv',
        params: { 'foreign_matchable_taxonomy_id' => iucn.id }, **attributes
      )
      yield import if block_given?
      Imports::MappingMatchesJob.perform_now(import.id)
      import.reload
    end

    it 'takes the near side from the row and the far side from its params' do
      run_matches

      expect(MappingMatch.sole).to have_attributes(
        matchable_taxonomy_id: cites.id, foreign_matchable_taxonomy_id: iucn.id
      )
    end

    it 'fails loudly when the far taxonomy has since been deleted' do
      expect { run_matches { iucn.destroy! } }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'records that it failed, so the upload does not sit there looking pending' do
      suppress(ActiveRecord::RecordNotFound) { run_matches { iucn.destroy! } }

      expect(ImportRun.sole.status).to eq ImportRun::FAILED
    end
  end
end
