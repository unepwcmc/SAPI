require 'aws-sdk-s3'
require 'set'

module ActiveStorage
  class StagingBucketCleanup
    DEFAULT_DELETE_BATCH_SIZE = 1_000
    DEFAULT_DB_BATCH_SIZE = 1_000

    Result = Struct.new(
      :scanned_objects_count,
      :orphaned_objects_count,
      :deleted_objects_count,
      :dry_run,
      keyword_init: true
    )

    def self.call(...)
      new(...).call
    end

    def initialize(
      s3_client:,
      bucket_name:,
      blob_scope: ::ActiveStorage::Blob.all,
      dry_run: true,
      delete_batch_size: DEFAULT_DELETE_BATCH_SIZE,
      db_batch_size: DEFAULT_DB_BATCH_SIZE,
      delete_only_if_last_modified_before: nil,
      logger: Rails.logger
    )
      @s3_client = s3_client
      @bucket_name = bucket_name
      @blob_scope = blob_scope
      @dry_run = dry_run
      @delete_batch_size = delete_batch_size
      @db_batch_size = db_batch_size
      @delete_only_if_last_modified_before = delete_only_if_last_modified_before
      @logger = logger
    end

    def call
      ensure_supported_environment!

      # We compare the staging bucket against the current staging DB because a
      # production DB restore can leave behind objects that Rails no longer
      # knows about. Cleaning from the DB view avoids one S3 existence check per
      # blob, which keeps the restore-time task cheap enough to run routinely.
      valid_blob_keys = load_valid_blob_keys
      orphan_keys_to_delete = []
      scanned_objects_count = 0
      orphaned_objects_count = 0
      deleted_objects_count = 0

      each_bucket_object do |object|
        scanned_objects_count += 1
        next if valid_blob_keys.include?(object.key)
        next if delete_only_if_last_modified_before.present? &&
          object.last_modified >= delete_only_if_last_modified_before

        orphan_keys_to_delete << object.key
        orphaned_objects_count += 1

        next unless orphan_keys_to_delete.size >= delete_batch_size

        deleted_objects_count += delete_keys(orphan_keys_to_delete)
        orphan_keys_to_delete.clear
      end

      deleted_objects_count += delete_keys(orphan_keys_to_delete) if orphan_keys_to_delete.any?

      Result.new(
        scanned_objects_count:,
        orphaned_objects_count:,
        deleted_objects_count:,
        dry_run:
      )
    end

  private

    attr_reader :blob_scope, :bucket_name, :db_batch_size, :delete_batch_size,
      :delete_only_if_last_modified_before, :dry_run, :logger, :s3_client

    def ensure_supported_environment!
      # This cleanup is intentionally limited to staging
      # because its job is to discard bucket objects that are no longer
      # represented in the current DB snapshot. That is appropriate for staging
      # restore hygiene, but it would be too destructive to allow elsewhere.
      return if Rails.env.staging?

      raise "#{self.class.name} only supports staging"
    end

    def load_valid_blob_keys
      keys = Set.new

      blob_scope.select(:key).in_batches(of: db_batch_size) do |relation|
        relation.pluck(:key).each { |key| keys.add(key) }
      end

      keys
    end

    def each_bucket_object
      continuation_token = nil

      loop do
        response = s3_client.list_objects_v2(
          bucket: bucket_name,
          continuation_token:
        )

        response.contents.each { |object| yield object }

        break unless response.is_truncated

        continuation_token = response.next_continuation_token
      end
    end

    def delete_keys(keys)
      if dry_run
        keys.each do |key|
          # Dry-run output needs to show the exact candidate keys so operators
          # can validate the deletion set before any irreversible cleanup.
          logger.info "ActiveStorage staging bucket cleanup dry run would delete key=#{key}"
        end
        logger.info "ActiveStorage staging bucket cleanup dry run would delete #{keys.size} objects"
        return 0
      end

      # S3 supports deleting up to 1,000 objects per request. Batching on that
      # boundary keeps request volume low without trying to issue a single huge
      # delete operation that S3 would reject.
      s3_client.delete_objects(
        bucket: bucket_name,
        delete: {
          objects: keys.map { |key| { key: } },
          quiet: true
        }
      )

      logger.info "ActiveStorage staging bucket cleanup deleted #{keys.size} objects"
      keys.size
    end
  end
end
