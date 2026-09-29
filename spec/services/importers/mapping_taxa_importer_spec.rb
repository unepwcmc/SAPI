require 'spec_helper'

describe Importers::MappingTaxaImporter do
  let(:matchable_taxonomy) { MatchableTaxonomy.create!(code: 'IUCNRL', name: 'IUCN Red List') }
  let(:headers) { 'Status,Id,Id_Accepted,Scientific.Name,Author' }

  def import(rows)
    file = Tempfile.new([ 'taxa', '.csv' ])
    file.write("#{headers}\n#{rows}")
    file.close
    described_class.new(file_path: file.path, matchable_taxonomy: matchable_taxonomy).tap(&:import!)
  ensure
    file&.unlink
  end

  it 'writes every name, not only the accepted ones' do
    import("A,1,1,Panthera leo,Linnaeus\nS,2,1,Felis leo,Schreber\n")

    expect(MappingTaxon.pluck(:taxon_nid, :name_status))
      .to contain_exactly([ '1', 'A' ], [ '2', 'S' ])
  end

  it 'keeps a blank identifier as NULL rather than an empty string' do
    # IUCN issues no id for a synonym; every other platform does.
    import("S,,42,Felis leo,Schreber\n")

    expect(MappingTaxon.sole).to have_attributes(taxon_nid: nil, accepted_taxon_nid: '42')
  end

  it 'keeps a blank accepted identifier as NULL' do
    # WoRMS nomina nuda were never validly published, so they point at nothing.
    import("S,7,,Acropora dumoa,Brook\n")

    expect(MappingTaxon.sole).to have_attributes(taxon_nid: '7', accepted_taxon_nid: nil)
  end

  it 'leaves rank_id unset until stage 1 emits a Rank column' do
    import("A,1,1,Panthera leo,Linnaeus\n")

    expect(MappingTaxon.sole.rank_id).to be_nil
  end

  it 'records the platform it was told to import as, and the file it came from' do
    importer = import("A,1,1,Panthera leo,Linnaeus\n")

    expect(MappingTaxon.sole).to have_attributes(
      matchable_taxonomy: matchable_taxonomy,
      source_file: File.basename(importer.file_path)
    )
  end

  it 'reports what it wrote' do
    importer = import("A,1,1,Panthera leo,Linnaeus\nA,2,2,Panthera pardus,Linnaeus\n")

    expect(importer.logs.last).to include(message: 'import completed', written: 2)
  end
end
