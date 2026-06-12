# == Schema Information
#
# Table name: documents_bulk_downloads
#
#  id               :bigint           not null, primary key
#  checksum         :string           not null
#  completed_at     :datetime
#  document_ids     :jsonb            not null
#  error_message    :text
#  last_download_at :datetime
#  processing_at    :datetime
#  status           :string           default("pending"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_documents_bulk_downloads_on_checksum          (checksum) UNIQUE
#  index_documents_bulk_downloads_on_last_download_at  (last_download_at)
#  index_documents_bulk_downloads_on_status            (status)
#

class DocumentsBulkDownload < ApplicationRecord
  PENDING = 'pending'
  PROCESSING = 'processing'
  COMPLETED = 'completed'
  FAILED = 'failed'

  STATUSES = [ PENDING, PROCESSING, COMPLETED, FAILED ].freeze

  # This table is intentionally separate from the legacy `Download` model
  # because that older flow assumes local filesystem artifacts under
  # `public/downloads/...`. This model exists for checksum-addressed ZIP
  # artifacts so the same document selection can reuse an existing generated
  # file without inheriting the old local-cache lifecycle.
  #
  # Active Storage still owns artifact metadata such as filename and storage
  # key; this row only tracks deduplication and lifecycle state.
  # `processing_at` records when the worker actually begins work, which is
  # distinct from the initial row creation time while the job is still only
  # queued.
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

  def touch_last_download_at!
    # Cache eviction should be based on the last successful reuse of a ready
    # ZIP, not merely on row creation time. We only advance this timestamp for
    # completed downloads so queued or failed rows do not look "recent" just
    # because the polling endpoint was hit again.
    return unless status == COMPLETED

    touch(:last_download_at)
  end

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
