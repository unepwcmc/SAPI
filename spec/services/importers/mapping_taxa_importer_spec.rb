require 'spec_helper'

describe Importers::MappingTaxaImporter do
  let(:matchable_taxonomy) { MatchableTaxonomy.create!(code: 'IUCNRL', name: 'IUCN Red List') }
  let(:headers) { 'Status,Id,Id_Accepted,Rank,Scientific.Name,Author' }

  def import(rows)
    file = Tempfile.new([ 'taxa', '.csv' ])
    file.write("#{headers}\n#{rows}")
    file.close
    described_class.new(file_path: file.path, matchable_taxonomy: matchable_taxonomy).tap(&:import!)
  ensure
    file&.unlink
  end

  it 'writes every name, not only the accepted ones' do
    import("A,1,1,SPECIES,Panthera leo,Linnaeus\nS,2,1,SPECIES,Felis leo,Schreber\n")

    expect(MappingTaxon.pluck(:taxon_nid, :name_status))
      .to contain_exactly([ '1', 'A' ], [ '2', 'S' ])
  end

  it 'keeps a blank identifier as NULL rather than an empty string' do
    # IUCN issues no id for a synonym; every other platform does.
    import("S,,42,SPECIES,Felis leo,Schreber\n")

    expect(MappingTaxon.sole).to have_attributes(taxon_nid: nil, accepted_taxon_nid: '42')
  end

  it 'keeps a blank accepted identifier as NULL' do
    # WoRMS nomina nuda were never validly published, so they point at nothing.
    import("S,7,,SPECIES,Acropora dumoa,Brook\n")

    expect(MappingTaxon.sole).to have_attributes(taxon_nid: '7', accepted_taxon_nid: nil)
  end

  describe 'Rank' do
    let!(:species) { create(:rank, name: 'SPECIES') }

    it 'resolves the name to a rank this application already holds' do
      import("A,1,1,SPECIES,Panthera leo,Linnaeus\n")

      expect(MappingTaxon.sole.rank).to eq species
    end

    it 'matches whatever case the file writes it in' do
      import("A,1,1,Species,Panthera leo,Linnaeus\n")

      expect(MappingTaxon.sole.rank).to eq species
    end

    it 'imports a name whose rank this application does not model' do
      # The Red List uses FORMA and SUBSPECIES (PLANTAE); `ranks` has neither,
      # and it is Species+ taxonomy shared with the rest of the app.
      import("A,1,1,FORMA,Cattleya trianae f. alba,Linden\n")

      expect(MappingTaxon.sole.rank_id).to be_nil
    end

    it 'says so once, however many names carry it' do
      importer = import(
        "A,1,1,FORMA,One,L\nA,2,2,FORMA,Two,L\nA,3,3,SUBSPECIES (PLANTAE),Three,L\n"
      )

      expect(importer.logs.count { |entry| entry[:level] == 'warning' }).to eq 2
    end

    it "reads R's NA as no rank at all" do
      import("A,1,1,NA,Panthera leo,Linnaeus\n")

      expect(MappingTaxon.sole.rank_id).to be_nil
    end

    it 'refuses an export that does not carry the column' do
      expect { import_without_rank }
        .to raise_error(Importer::Base::ImportError, /Missing required headers: Rank/)
    end

    def import_without_rank
      file = Tempfile.new([ 'taxa', '.csv' ])
      file.write("Status,Id,Id_Accepted,Scientific.Name,Author\nA,1,1,Panthera leo,L\n")
      file.close
      described_class.new(
        file_path: file.path, matchable_taxonomy: matchable_taxonomy
      ).import!
    ensure
      file&.unlink
    end
  end

  it 'records the platform it was told to import as, and the file it came from' do
    importer = import("A,1,1,SPECIES,Panthera leo,Linnaeus\n")

    expect(MappingTaxon.sole).to have_attributes(
      matchable_taxonomy: matchable_taxonomy,
      source_file: File.basename(importer.file_path)
    )
  end

  it 'reports what it wrote' do
    importer = import("A,1,1,SPECIES,Panthera leo,Linnaeus\nA,2,2,SPECIES,Panthera pardus,Linnaeus\n")

    expect(importer.logs.last).to include(message: 'import completed', written: 2)
  end
end
