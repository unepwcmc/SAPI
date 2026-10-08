require 'spec_helper'

describe ImportRun do
  let(:taxonomy) { MatchableTaxonomy.create!(code: 'CITES_EU', name: 'CITES / EU') }

  def build_import(kind: 'mapping_taxa', attach: true, **attributes)
    described_class.new(kind: kind, importable: taxonomy, **attributes).tap do |import|
      next unless attach

      import.file.attach(
        io: StringIO.new("Status,Id\nA,1\n"), filename: 'cites_eu.csv', content_type: 'text/csv'
      )
    end
  end

  describe 'validation' do
    it 'refuses a kind no job answers to' do
      import = build_import(kind: 'whatever')
      import.valid?

      expect(import.errors[:kind]).to be_present
    end

    it 'refuses an upload with no file' do
      import = build_import(attach: false)
      import.valid?

      expect(import.errors[:file]).to be_present
    end

    it 'accepts one of each kind it knows' do
      expect(described_class::JOBS.keys).to all(satisfy { |kind| build_import(kind: kind).valid? })
    end
  end

  describe 'a new row' do
    it 'starts pending' do
      expect(build_import.tap(&:save!)).to be_pending
    end

    it 'hands itself to the job its kind names' do
      import = build_import(kind: 'mapping_matches')

      expect { import.save! }.to have_enqueued_job(Imports::MappingMatchesJob).with(import.id)
    end

    it 'enqueues nothing when it does not save' do
      expect { build_import(kind: 'whatever').save }.not_to have_enqueued_job
    end
  end

  describe '#filename' do
    it 'is the name the admin uploaded, which names the export to replace' do
      expect(build_import.filename).to eq 'cites_eu.csv'
    end

    it 'is nil with nothing attached' do
      expect(build_import(attach: false).filename).to be_nil
    end
  end

  describe '#duration' do
    it 'is nil until the job has both finished and started' do
      expect(build_import(started_at: Time.current).duration).to be_nil
    end

    it 'is the time the job took' do
      started = Time.current

      expect(build_import(started_at: started, finished_at: started + 90).duration).to eq 90
    end
  end

  describe '.recent' do
    it 'puts the newest upload first' do
      # Two rows saved in the same second would otherwise tie.
      travel_to(1.day.ago) { build_import.save! }
      newer = build_import.tap(&:save!)

      expect(described_class.recent.first).to eq newer
    end
  end
end
