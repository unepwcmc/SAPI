require 'spec_helper'

describe Mapping::FileImport do
  let(:cites) { MatchableTaxonomy.create!(code: 'CITES_EU', name: 'CITES / EU') }
  let(:iucn) { MatchableTaxonomy.create!(code: 'IUCNRL', name: 'IUCN Red List') }

  let(:taxa_csv) do
    "Status,Id,Id_Accepted,Rank,Scientific.Name,Author\n" \
      "A,1,1,SPECIES,Panthera leo,Linnaeus\nS,2,1,SPECIES,Felis leo,Schreber\n"
  end
  let(:match_headers) do
    'd1_Id_Accepted,d1_Scientific.Name,d1_Status,' \
      'd2_Id_Accepted,d2_Scientific.Name,d2_Status,confidence_level,exclude'
  end
  let(:match_rows) do
    "1,Handroanthus serratifolius,A,9,Handroanthus serratifolius,A,high,NA\n" \
      "1,Tabebuia serratifolia,S,9,Tabebuia serratifolia,S,really high,NA\n"
  end

  def csv(contents)
    file = Tempfile.new([ 'import', '.csv' ])
    file.write(contents)
    file.close
    yield file.path
  ensure
    file&.unlink
  end

  def import_taxa(contents = taxa_csv, into: cites)
    csv(contents) { |path| described_class.taxa(file_path: path, matchable_taxonomy: into) }
  end

  def import_matches(near: cites, far: iucn, headers: match_headers, rows: match_rows)
    csv("#{headers}\n#{rows}") do |path|
      described_class.matches(
        file_path: path, matchable_taxonomy: near, foreign_matchable_taxonomy: far
      )
    end
  end

  describe '.taxa' do
    it 'reports what it wrote and what survived' do
      expect(import_taxa).to have_attributes(success?: true, written: 2, retained: 2)
    end

    it 'replaces the platform rather than adding to it' do
      2.times { import_taxa }

      expect(MappingTaxon.count).to eq 2
    end

    it 'leaves the other platforms alone' do
      import_taxa(into: iucn)
      import_taxa(into: cites)

      expect(MappingTaxon.where(matchable_taxonomy: iucn).count).to eq 2
    end

    it 'rolls the clear back when the file turns out to be unusable' do
      import_taxa
      import_taxa("Wrong,Headers\n1,2\n")

      expect(MappingTaxon.count).to eq 2
    end

    it 'reports a file it would not read as a failure' do
      expect(import_taxa("Wrong,Headers\n1,2\n")).to be_failure
    end

    it 'says why it would not read it' do
      # Nothing is logged before the header check, so without this message the
      # admin page would show a failure it could not explain.
      result = import_taxa("Wrong,Headers\n1,2\n")

      expect(result.logs.last[:message]).to include 'Missing required headers'
    end
  end

  describe '.matches' do
    it 'collapses the file to one row per concept pair' do
      expect(import_matches).to have_attributes(success?: true, written: 2, retained: 1)
    end

    it 'keeps the direct match, not the higher-scoring bridged one' do
      import_matches

      expect(MappingMatch.sole.match_type).to eq 'AA'
    end

    describe 'a file that disagrees about which taxonomies it is about' do
      # The same rows, each stating the pair the other way round.
      def import_labelled
        import_matches(
          headers: "#{match_headers},d1_dataset,d2_dataset",
          rows: match_rows.lines.map { |row| "#{row.chomp},IUCNRL,CITES_EU\n" }.join
        )
      end

      it 'reports a failure rather than raising' do
        expect(import_labelled).to be_failure
      end

      it 'says which way round the file actually is' do
        expect(import_labelled.logs.last[:message]).to include 'other way round'
      end

      it 'leaves what was already loaded in place' do
        # The clear runs before the insert, so the guarantee worth testing is
        # that refusing the file rolls it back rather than emptying the pair.
        import_matches

        import_labelled

        expect(MappingMatch.count).to eq 1
      end
    end

    it 'clears the pair whichever orientation the file used' do
      import_matches(near: cites, far: iucn)
      # A later export may name the file the other way round, putting IUCN in d1.
      import_matches(near: iucn, far: cites)

      expect(MappingMatch.count).to eq 1
    end
  end
end
