# == Schema Information
#
# Table name: download_zips
#
#  id            :bigint           not null, primary key
#  checksum     :string           not null
#  document_ids :jsonb            not null
#  error_message :text
#  processing_at :datetime
#  status       :string           default("pending"), not null
#  completed_at  :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class DownloadZip < ApplicationRecord
  PENDING   = 'pending'
  PROCESSING = 'processing'
  COMPLETED = 'completed'
  FAILED    = 'failed'

  STATUSES = [ PENDING, PROCESSING, COMPLETED, FAILED ].freeze

  # This table is intentionally separate from the legacy `Download` model
  # because that older flow assumes local filesystem artifacts under
  # `public/downloads/...`. This model exists for checksum-addressed ZIP
  # artifacts so the same document selection can reuse an existing generated
  # file without inheriting the old local-cache lifecycle.
  #
  # We intentionally do not duplicate artifact metadata such as filename or
  # storage key here because the ZIP itself will live in Active Storage, which
  # already owns that information. This table only keeps the state needed to
  # deduplicate requests and track generation progress. `processing_at`
  # records the moment the worker actually begins work, which is distinct from
  # the initial row creation time while the job is still only queued.
  has_one_attached :zip_file

  # Generation must start only after commit so the worker never races against
  # an uncommitted row. This keeps the entry point simple for controllers:
  # create the record, and the asynchronous ZIP lifecycle starts itself.
  after_commit :enqueue_zip_generation, on: :create

  # Checksum deduplication is enforced by the database unique index instead of
  # an application-level uniqueness validation. `create_or_find_by!` relies on
  # that index to collapse concurrent creates into one row; a model validation
  # would fail too early with `RecordInvalid` and prevent the fallback lookup.
  validates :checksum, presence: true
  validates :document_ids, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validate :completed_download_must_have_attached_zip

private

  def enqueue_zip_generation
    GenerateDocumentsBulkDownloadJob.perform_later(id)
  end

  def completed_download_must_have_attached_zip
    # A completed row is the public contract that a signed download URL can be
    # generated immediately. Enforcing the attachment here keeps that contract
    # explicit and prevents the controller from returning a misleading
    # "completed" response with no downloadable artifact behind it.
    return unless status == COMPLETED
    return if zip_file.attached?

    errors.add(:zip_file, 'must be attached when the download zip is completed')
  end
end
