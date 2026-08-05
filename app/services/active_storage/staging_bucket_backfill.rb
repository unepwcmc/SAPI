require 'aws-sdk-s3'
require 'cgi'
require 'set'

module ActiveStorage
  class StagingBucketBackfill
    DEFAULT_DB_BATCH_SIZE = 1_000

    Result = Struct.new(
      :scanned_blob_keys_count,
      :missing_in_staging_count,
      :copied_objects_count,
      :missing_in_production_count,
      :dry_run,
      keyword_init: true
    )

    def self.call(...)
      new(...).call
    end

    def initialize(
      s3_client:,
      source_bucket_name:,
      destination_bucket_name:,
      blob_scope: ::ActiveStorage::Blob.all,
      dry_run: true,
      db_batch_size: DEFAULT_DB_BATCH_SIZE,
      logger: Rails.logger
    )
      @s3_client = s3_client
      @source_bucket_name = source_bucket_name
      @destination_bucket_name = destination_bucket_name
      @blob_scope = blob_scope
      @dry_run = dry_run
      @db_batch_size = db_batch_size
      @logger = logger
    end

    def call
      ensure_supported_environment!

      # The one-off restore repair should avoid one S3 existence check per blob.
      # Listing the destination bucket once and diffing against DB keys keeps
      # the repair cost proportional to bucket pages plus actual copies.
      destination_keys = load_bucket_keys(destination_bucket_name)
      scanned_blob_keys_count = 0
      missing_in_staging_count = 0
      copied_objects_count = 0
      missing_in_production_count = 0

      blob_scope.select(:key).in_batches(of: db_batch_size) do |relation|
        relation.pluck(:key).each do |key|
          scanned_blob_keys_count += 1
          next if destination_keys.include?(key)

          missing_in_staging_count += 1

          if dry_run
            logger.info "ActiveStorage staging bucket backfill dry run would copy key=#{key}"
            next
          end

          copied_objects_count += copy_key_from_production(key)
        rescue Aws::S3::Errors::NoSuchKey
          missing_in_production_count += 1
          logger.warn "ActiveStorage staging bucket backfill could not find production key=#{key}"
        end
      end

      Result.new(
        scanned_blob_keys_count:,
        missing_in_staging_count:,
        copied_objects_count:,
        missing_in_production_count:,
        dry_run:
      )
    end

  private

    attr_reader :blob_scope, :db_batch_size, :destination_bucket_name, :dry_run,
      :logger, :s3_client, :source_bucket_name

    def ensure_supported_environment!
      # This repair copies production-backed files into staging to match a
      # restored staging DB. Restricting it to staging prevents accidental
      # cross-environment copying in production.
      return if Rails.env.staging?

      raise "#{self.class.name} only supports staging"
    end

    def load_bucket_keys(bucket_name)
      keys = Set.new
      continuation_token = nil

      loop do
        response = s3_client.list_objects_v2(
          bucket: bucket_name,
          continuation_token:
        )

        response.contents.each { |object| keys.add(object.key) }
        break unless response.is_truncated

        continuation_token = response.next_continuation_token
      end

      keys
    end

    def copy_key_from_production(key)
      s3_client.copy_object(
        bucket: destination_bucket_name,
        key:,
        copy_source: "#{source_bucket_name}/#{CGI.escape(key).gsub('+', '%20')}"
      )

      logger.info "ActiveStorage staging bucket backfill copied key=#{key}"
      1
    end
  end
end
