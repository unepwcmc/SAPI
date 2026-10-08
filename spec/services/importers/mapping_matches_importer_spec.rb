require 'spec_helper'

describe Importers::MappingMatchesImporter do
  def import_run = @import_run ||= create(:import_run)
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

  def import(headers, rows, near: cites, far: iucn)
    file = Tempfile.new([ 'matches', '.csv' ])
    file.write("#{headers}\n#{rows}")
    file.close
    described_class.new(
      file_path: file.path, matchable_taxonomy: near, foreign_matchable_taxonomy: far,
      import_run: import_run
    ).tap(&:import!)
  ensure
    file&.unlink
  end

  describe 'a match a person asserted' do
    # No automatic rule fired, so the pipeline writes NA for the rule and for
    # both name statuses. All three in the October export look like this.
    let(:verified) { '100196,Nephrurus cinctus,NA,178261,Nephrurus wheeleri,NA,verified,NA' }

    it 'keeps it, even though no rule matched' do
      import(wide_headers, "NA,#{verified}\n")

      expect(MappingMatch.count).to eq 1
    end

    it 'leaves it with no match type, rather than inventing one' do
      import(wide_headers, "NA,#{verified}\n")

      expect(MappingMatch.sole.match_type).to be_nil
    end

    it 'still drops a row that carries neither a rule nor a confidence' do
      import(wide_headers, "NA,1,Panthera leo,A,9,Panthera leo,A,NA,NA\n")

      expect(MappingMatch.count).to eq 0
    end
  end

  describe 'the taxonomies the file says it is about' do
    # The October exports name each side. The upload form still asks, because
    # the admin is choosing what gets replaced.
    # Methods rather than lets: these are fixtures, not state under test.
    def row = '1,Panthera leo,A,9,Panthera leo,A,high,NA'

    def import_labelled(d1, d2, near: cites, far: iucn)
      import(
        "#{narrow_headers},d1_dataset,d2_dataset", "#{row},#{d1},#{d2}\n",
        near: near, far: far
      )
    end

    it 'imports a file that agrees with what it was uploaded as' do
      import_labelled('CITES_EU', 'IUCNRL')

      expect(MappingMatch.count).to eq 1
    end

    it 'accepts a code in any case, since these are machine-written constants' do
      import_labelled('cites_eu', 'iucnrl')

      expect(MappingMatch.count).to eq 1
    end

    it 'refuses a file about another pair' do
      expect { import_labelled('CITES_EU', 'Kew') }
        .to raise_error(Importer::Base::ImportError, /matches CITES_EU to Kew/)
    end

    it 'writes nothing when it refuses' do
      suppress(Importer::Base::ImportError) { import_labelled('IUCNRL', 'CITES_EU') }

      expect(MappingMatch.count).to eq 0
    end

    it 'says so plainly when the two were picked the wrong way round' do
      # Both taxonomies right, chosen in the other order - the likeliest slip,
      # and the one a bare mismatch message would not explain.
      expect { import_labelled('IUCNRL', 'CITES_EU') }
        .to raise_error(Importer::Base::ImportError, /other way round/)
    end

    it 'has nothing to check in an export from before the columns existed' do
      import(narrow_headers, "#{row}\n")

      expect(MappingMatch.count).to eq 1
    end

    it 'treats R\'s NA as saying nothing either' do
      import_labelled('NA', 'NA')

      expect(MappingMatch.count).to eq 1
    end
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
