require 'spec_helper'

describe Admin::TaxonMappings::UploadsController do
  let!(:cites) { MatchableTaxonomy.create!(code: 'CITES_EU', name: 'CITES / EU') }
  let!(:iucn) { MatchableTaxonomy.create!(code: 'IUCNRL', name: 'IUCN Red List') }

  def file(name = 'cites_eu.csv')
    Rack::Test::UploadedFile.new(
      StringIO.new("Status,Id\nA,1\n"), 'text/csv', original_filename: name
    )
  end

  def upload(attributes)
    post :create, params: { upload: { file: file }.merge(attributes) }
  end

  describe 'as a manager' do
    login_admin

    it 'records a taxa upload against the taxonomy it was told' do
      upload(kind: 'mapping_taxa', matchable_taxonomy_id: cites.id)

      expect(Import.sole.importable).to eq cites
    end

    it 'keeps the file, which is what names the export to replace' do
      upload(kind: 'mapping_taxa', matchable_taxonomy_id: cites.id)

      expect(Import.sole.filename).to eq 'cites_eu.csv'
    end

    it 'records who uploaded it' do
      # Set here rather than by TrackWhoDoesIt: an import is only ever changed
      # afterwards by its own job, so there is no updater worth recording.
      upload(kind: 'mapping_taxa', matchable_taxonomy_id: cites.id)

      expect(Import.sole.creator).to eq controller.current_user
    end

    it 'takes a file the browser already put in storage' do
      # What a direct upload submits is a signed id, not a multipart body.
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new("Status,Id\nA,1\n"), filename: 'cites_eu.csv', content_type: 'text/csv'
      )

      post :create, params: {
        upload: { kind: 'mapping_taxa', matchable_taxonomy_id: cites.id, file: blob.signed_id }
      }

      expect(Import.sole.file.blob).to eq blob
    end

    it 'hands it to the job for its kind' do
      expect { upload(kind: 'mapping_taxa', matchable_taxonomy_id: cites.id) }
        .to have_enqueued_job(Imports::MappingTaxaJob)
    end

    it 'carries the far side of a match upload in params' do
      upload(
        kind: 'mapping_matches', matchable_taxonomy_id: cites.id,
        foreign_matchable_taxonomy_id: iucn.id
      )

      expect(Import.sole.params).to eq('foreign_matchable_taxonomy_id' => iucn.id.to_s)
    end

    it 'leaves a taxa upload no far side to be confused by' do
      upload(
        kind: 'mapping_taxa', matchable_taxonomy_id: cites.id,
        foreign_matchable_taxonomy_id: iucn.id
      )

      expect(Import.sole.params).to eq({})
    end

    describe 'while one is already running' do
      def running(kind:, importable:, far: nil)
        Import.new(
          kind: kind, importable: importable, status: Import::RUNNING,
          params: far ? { 'foreign_matchable_taxonomy_id' => far.id.to_s } : {}
        ).tap do |import|
          import.file.attach(
            io: StringIO.new('x'), filename: 'earlier.csv', content_type: 'text/csv'
          )
          import.save!
        end
      end

      it 'refuses a second upload into the same taxonomy' do
        running(kind: 'mapping_taxa', importable: cites)

        upload(kind: 'mapping_taxa', matchable_taxonomy_id: cites.id)

        expect(Import.count).to eq 1
      end

      it 'names the file already running' do
        running(kind: 'mapping_taxa', importable: cites)

        upload(kind: 'mapping_taxa', matchable_taxonomy_id: cites.id)

        expect(flash[:alert]).to include 'earlier.csv'
      end

      it 'allows a different taxonomy, which shares nothing with it' do
        running(kind: 'mapping_taxa', importable: cites)

        upload(kind: 'mapping_taxa', matchable_taxonomy_id: iucn.id)

        expect(Import.count).to eq 2
      end

      it 'allows a match upload while a taxa upload runs' do
        running(kind: 'mapping_taxa', importable: cites)

        upload(
          kind: 'mapping_matches', matchable_taxonomy_id: cites.id,
          foreign_matchable_taxonomy_id: iucn.id
        )

        expect(Import.count).to eq 2
      end

      it 'refuses the same pair uploaded the other way round' do
        # A match upload clears the pair in both orientations, so which side the
        # earlier file called d1 makes no difference to what it replaces.
        running(kind: 'mapping_matches', importable: iucn, far: cites)

        upload(
          kind: 'mapping_matches', matchable_taxonomy_id: cites.id,
          foreign_matchable_taxonomy_id: iucn.id
        )

        expect(Import.count).to eq 1
      end

      it 'allows a different pair' do
        gard = MatchableTaxonomy.create!(code: 'GARD', name: 'GARD')
        running(kind: 'mapping_matches', importable: cites, far: iucn)

        upload(
          kind: 'mapping_matches', matchable_taxonomy_id: cites.id,
          foreign_matchable_taxonomy_id: gard.id
        )

        expect(Import.count).to eq 2
      end

      it 'lets a finished one be replaced' do
        running(kind: 'mapping_taxa', importable: cites).update!(status: Import::DONE)

        upload(kind: 'mapping_taxa', matchable_taxonomy_id: cites.id)

        expect(Import.count).to eq 2
      end
    end

    describe 'refusing an upload' do
      it 'needs a taxonomy' do
        upload(kind: 'mapping_taxa', matchable_taxonomy_id: '')

        expect(Import.count).to eq 0
      end

      it 'says so' do
        upload(kind: 'mapping_taxa', matchable_taxonomy_id: '')

        expect(flash[:alert]).to include 'taxonomy'
      end

      it 'needs both sides of a match file' do
        upload(
          kind: 'mapping_matches', matchable_taxonomy_id: cites.id,
          foreign_matchable_taxonomy_id: ''
        )

        expect(Import.count).to eq 0
      end

      it 'refuses a match file relating a taxonomy to itself' do
        # The scope is written in both orientations, so this would clear the
        # taxonomy's matches against everything else.
        upload(
          kind: 'mapping_matches', matchable_taxonomy_id: cites.id,
          foreign_matchable_taxonomy_id: cites.id
        )

        expect(Import.count).to eq 0
      end

      it 'needs a file' do
        post :create, params: { upload: { kind: 'mapping_taxa', matchable_taxonomy_id: cites.id } }

        expect(Import.count).to eq 0
      end
    end
  end

  describe 'as a contributor' do
    login_contributor

    it 'is refused' do
      upload(kind: 'mapping_taxa', matchable_taxonomy_id: cites.id)

      expect(Import.count).to eq 0
    end
  end
end
