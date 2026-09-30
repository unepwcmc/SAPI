# One upload, whatever it turns out to contain.
#
# This is the table and nothing more: the file, who sent it, what happened, and
# which job to hand it to. How that job runs - which importers, how many files,
# what it clears first, what it wraps in a transaction - is the job's business,
# because none of that generalises across the things people import.
#
# An upload outlives its request; the largest mapping file is 209 MB and takes
# about 45 seconds. The row is what the admin page reads afterwards.
# == Schema Information
#
# Table name: imports
#
#  id              :bigint           not null, primary key
#  finished_at     :datetime
#  importable_type :string
#  kind            :string           not null
#  logs            :jsonb            not null
#  params          :jsonb            not null
#  started_at      :datetime
#  status          :string           default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  created_by_id   :integer
#  importable_id   :bigint
#
# Indexes
#
#  index_imports_on_created_by_id          (created_by_id)
#  index_imports_on_importable             (importable_type,importable_id)
#  index_imports_on_kind                   (kind)
#  index_imports_on_status_and_created_at  (status,created_at)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#
class Import < ApplicationRecord
  PENDING = 'pending'.freeze
  RUNNING = 'running'.freeze
  DONE = 'done'.freeze
  FAILED = 'failed'.freeze
  STATUSES = [ PENDING, RUNNING, DONE, FAILED ].freeze

  # What each kind of upload is handed to. Named rather than referenced so a
  # class can be renamed without stranding rows, and so nothing stored in the
  # database decides what code gets loaded.
  JOBS = {
    'mapping_taxa' => 'Imports::MappingTaxaJob',
    'mapping_matches' => 'Imports::MappingMatchesJob'
  }.freeze

  # Optional because some uploads are about a combination rather than a record:
  # a mapping match file covers a pair of taxonomies and neither is the subject.
  belongs_to :importable, polymorphic: true, optional: true

  # Set by whoever uploads, not by TrackWhoDoesIt: that concern also maintains
  # an updater, and the only thing that updates an import is its own job.
  belongs_to :creator, class_name: 'User', foreign_key: :created_by_id,
    optional: true, inverse_of: false

  has_one_attached :file

  validates :kind, presence: true, inclusion: { in: JOBS.keys }
  validates :status, inclusion: { in: STATUSES }
  validate :file_attached

  after_commit :enqueue, on: :create

  scope :recent, -> { order(created_at: :desc) }
  # Callers name the kinds they own. The table holds everyone's imports, and a
  # page that shows another feature's uploads is worse than showing none.
  scope :of_kind, ->(kinds) { where(kind: kinds) }

  def pending? = status == PENDING
  def running? = status == RUNNING
  def failed? = status == FAILED

  # The name the admin uploaded, which is what identifies the export to whoever
  # has to produce a replacement.
  def filename
    file.attached? ? file.filename.to_s : nil
  end

  def duration
    return nil unless started_at && finished_at

    finished_at - started_at
  end

  private

  def file_attached
    errors.add(:file, 'must be attached') unless file.attached?
  end

  def enqueue
    JOBS.fetch(kind).constantize.perform_later(id)
  end
end
