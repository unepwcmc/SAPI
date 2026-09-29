require 'spec_helper'

describe Importers::MappingMatchesImporter do
  let(:cites) { MatchableTaxonomy.create!(code: 'CITES_EU', name: 'CITES / EU') }
  let(:iucn) { MatchableTaxonomy.create!(code: 'IUCNRL', name: 'IUCN Red List') }

  let(:wide_headers) do
    'matched,d1_Id_Accepted,d1_Scientific.Name,d1_Status,' \
      'd2_Id_Accepted,d2_Scientific.Name,d2_Status,confidence_level,exclude'
  end
  let(:narrow_headers) do
    'd1_Id_Accepted,d1_Scientific.Name,d1_Status,' \
      'd2_Id_Accepted,d2_Scientific.Name,d2_Status,confidence_level,exclude'
  end

  def import(headers, rows)
    file = Tempfile.new([ 'matches', '.csv' ])
    file.write("#{headers}\n#{rows}")
    file.close
    described_class.new(
      file_path: file.path, matchable_taxonomy: cites, foreign_matchable_taxonomy: iucn
    ).tap(&:import!)
  ensure
    file&.unlink
  end

  it 'skips the candidate rows that did not match' do
    # 95% of the wide export is unmatched candidates carrying `matched = NA`.
    importer = import(
      wide_headers,
      "d1_sci_name_matching,1,Panthera leo,A,9,Panthera leo,A,high,NA\n" \
      "NA,2,Felis catus,A,8,Felis catus,A,NA,NA\n"
    )

    expect(importer.logs.last).to include(written: 1, excluded: 1)
  end

  it 'imports every row when the narrower format omits the matched column' do
    import(narrow_headers, "1,Panthera leo,A,9,Panthera leo,A,high,NA\n")

    expect(MappingMatch.count).to eq 1
  end

  it 'reads NA in the exclude column as not excluded' do
    # The column is NOT NULL and R writes NA for unset.
    import(narrow_headers, "1,Panthera leo,A,9,Panthera leo,A,high,NA\n")

    expect(MappingMatch.sole.exclude).to be false
  end

  it 'reads a set exclude column as excluded' do
    import(narrow_headers, "1,Panthera leo,A,9,Panthera leo,A,high,TRUE\n")

    expect(MappingMatch.sole.exclude).to be true
  end

  it 'stores each side against the platform it was told, in the file order' do
    import(narrow_headers, "1,Panthera leo,A,9,Micromussa amakusensis,S,high,NA\n")

    expect(MappingMatch.sole).to have_attributes(
      matchable_taxonomy: cites,
      taxon_nid: '1',
      matched_name: 'Panthera leo',
      foreign_matchable_taxonomy: iucn,
      foreign_taxon_nid: '9',
      foreign_matched_name: 'Micromussa amakusensis'
    )
  end

  it 'derives the match type from the two name statuses' do
    import(narrow_headers, "1,Panthera leo,A,9,Micromussa amakusensis,S,high,NA\n")

    expect(MappingMatch.sole.match_type).to eq 'AS'
  end

  it 'keeps a match whose accepted id has no taxon, leaving that to the reader' do
    # The taxa file for either side may not have been uploaded yet, so checking
    # here would force an upload order. The API's inner join hides these.
    import(narrow_headers, "999,Ghost name,A,9,Panthera leo,A,high,NA\n")

    expect(MappingMatch.count).to eq 1
  end
end
