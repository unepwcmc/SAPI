# Usage:
#   bundle exec rake active_storage:cleanup_orphaned_objects
#   DRY_RUN=false bundle exec rake active_storage:cleanup_orphaned_objects
#
# Requirements:
# - Only run this in staging. Production is hard-blocked because
#   the task deletes bucket objects that are not represented by the current DB.
# - The ActiveStorage service must be S3-backed.
# - Run this before any new file upload happens in staging after the DB restore.
#   The task uses the latest ActiveStorage blob timestamp in the restored DB as
#   the safety cutoff, so new staging uploads after the restore can move that
#   cutoff forward and make cleanup more conservative.
# - The task assumes a restore workflow where staging can contain:
#   - old staging-only objects that disappeared from the restored DB and should
#     be deleted
#   - newer replicated production objects that are not in the restored DB yet
#     and must be preserved for the next restore
# - To preserve those newer replicated objects, the task only deletes orphaned
#   objects older than the latest ActiveStorage blob row.
#
namespace :active_storage do
  desc 'Delete S3 objects that no longer have an active_storage_blobs row'
  task cleanup_orphaned_objects: :environment do
    unless Rails.env.staging?
      raise 'active_storage:cleanup_orphaned_objects only supports staging'
    end

    service_name = Rails.application.config.active_storage.service
    service_config = Rails.application.config.active_storage
      .service_configurations
      .fetch(service_name.to_s)
    service_type = service_config.fetch('service')

    unless service_type == 'S3'
      raise "active_storage:cleanup_orphaned_objects requires an S3-backed ActiveStorage service, got #{service_type.inspect}"
    end

    # After a production DB restore, the latest blob row timestamp is a
    # practical snapshot boundary: objects replicated into staging after
    # that point will not exist in the restored DB yet, so deleting them
    # would recreate the missing-file problem on the next restore.
    delete_only_if_last_modified_before = ActiveStorage::Blob.maximum(:created_at)
    dry_run = ENV.fetch('DRY_RUN', 'true') != 'false'

    s3_client = Aws::S3::Client.new(
      access_key_id: service_config['access_key_id'],
      secret_access_key: service_config['secret_access_key'],
      session_token: service_config['session_token'],
      region: service_config['region'],
      endpoint: service_config['endpoint'],
      force_path_style: service_config['force_path_style']
    )

    # This task is meant for post-restore cleanup where clear operator
    # feedback matters more than silent success, so we log the exact bucket
    # and safety settings on every run.
    Rails.logger.info(
      "ActiveStorage staging bucket cleanup configured for bucket=#{service_config['bucket']} dry_run=#{dry_run} delete_only_if_last_modified_before=#{delete_only_if_last_modified_before || 'none'} delete_only_if_last_modified_before_source=active_storage_blobs.maximum(:created_at)"
    )

    result = ActiveStorage::StagingBucketCleanup.call(
      s3_client:,
      bucket_name: service_config.fetch('bucket'),
      dry_run:,
      delete_only_if_last_modified_before:
    )

    summary = [
      "scanned=#{result.scanned_objects_count}",
      "orphaned=#{result.orphaned_objects_count}",
      "deleted=#{result.deleted_objects_count}",
      "dry_run=#{result.dry_run}"
    ].join(' ')

    Rails.logger.info("ActiveStorage staging bucket cleanup complete #{summary}")
    puts summary
  end
end
