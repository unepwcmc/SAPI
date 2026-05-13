require 'spec_helper'

describe ActiveStorage::StagingBucketCleanup do
  let(:s3_client) { instance_double(Aws::S3::Client) }
  let(:logger) { instance_double(ActiveSupport::Logger, info: true) }
  let(:blob_scope) { class_double(ActiveStorage::Blob) }
  let(:bucket_name) { 'species-plus-staging' }
  let(:first_relation) { instance_double(ActiveRecord::Relation) }
  let(:second_relation) { instance_double(ActiveRecord::Relation) }
  let(:first_page_object) { instance_double(Aws::S3::Types::Object, key: 'kept-key', last_modified: 3.days.ago) }
  let(:second_page_object) { instance_double(Aws::S3::Types::Object, key: 'orphan-key', last_modified: 3.days.ago) }
  let(:first_page_response) do
    instance_double(
      Aws::S3::Types::ListObjectsV2Output,
      contents: [ first_page_object ],
      is_truncated: true,
      next_continuation_token: 'page-2'
    )
  end
  let(:second_page_response) do
    instance_double(
      Aws::S3::Types::ListObjectsV2Output,
      contents: [ second_page_object ],
      is_truncated: false,
      next_continuation_token: nil
    )
  end

  before do
    allow(blob_scope).to receive(:select).with(:key).and_return(blob_scope)
    allow(blob_scope).to receive(:in_batches).with(of: 2).and_yield(first_relation).and_yield(second_relation)
    allow(first_relation).to receive(:pluck).with(:key).and_return([ 'kept-key' ])
    allow(second_relation).to receive(:pluck).with(:key).and_return([ 'another-kept-key' ])
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('staging'))
  end

  it 'scans the bucket once and batch deletes only orphaned keys' do
    expect(s3_client).to receive(:list_objects_v2).with(
      bucket: bucket_name,
      continuation_token: nil
    ).and_return(first_page_response)
    expect(s3_client).to receive(:list_objects_v2).with(
      bucket: bucket_name,
      continuation_token: 'page-2'
    ).and_return(second_page_response)
    expect(s3_client).to receive(:delete_objects).with(
      bucket: bucket_name,
      delete: {
        objects: [ { key: 'orphan-key' } ],
        quiet: true
      }
    )

    result = described_class.call(
      s3_client:,
      bucket_name:,
      blob_scope:,
      dry_run: false,
      db_batch_size: 2,
      logger:
    )

    expect(result.scanned_objects_count).to eq(2)
    expect(result.orphaned_objects_count).to eq(1)
    expect(result.deleted_objects_count).to eq(1)
    expect(result.dry_run).to be(false)
  end

  it 'respects dry run safeguards' do
    first_object = instance_double(Aws::S3::Types::Object, key: 'first-orphan', last_modified: 12.hours.ago)
    second_object = instance_double(Aws::S3::Types::Object, key: 'second-orphan', last_modified: 5.days.ago)
    response = instance_double(
      Aws::S3::Types::ListObjectsV2Output,
      contents: [ first_object, second_object ],
      is_truncated: false,
      next_continuation_token: nil
    )

    expect(s3_client).to receive(:list_objects_v2).with(
      bucket: bucket_name,
      continuation_token: nil
    ).and_return(response)
    expect(s3_client).not_to receive(:delete_objects)

    result = described_class.call(
      s3_client:,
      bucket_name:,
      blob_scope:,
      dry_run: true,
      db_batch_size: 2,
      logger:
    )

    expect(result.scanned_objects_count).to eq(2)
    expect(result.orphaned_objects_count).to eq(2)
    expect(result.deleted_objects_count).to eq(0)
    expect(result.dry_run).to be(true)
  end

  it 'keeps orphaned objects that were created after the restore cutoff' do
    pre_restore_object = instance_double(
      Aws::S3::Types::Object,
      key: 'old-orphan',
      last_modified: Time.zone.parse('2026-05-13 08:00:00 UTC')
    )
    post_restore_replica = instance_double(
      Aws::S3::Types::Object,
      key: 'future-prod-replica',
      last_modified: Time.zone.parse('2026-05-13 10:00:00 UTC')
    )
    response = instance_double(
      Aws::S3::Types::ListObjectsV2Output,
      contents: [ pre_restore_object, post_restore_replica ],
      is_truncated: false,
      next_continuation_token: nil
    )

    expect(s3_client).to receive(:list_objects_v2).with(
      bucket: bucket_name,
      continuation_token: nil
    ).and_return(response)
    expect(s3_client).to receive(:delete_objects).with(
      bucket: bucket_name,
      delete: {
        objects: [ { key: 'old-orphan' } ],
        quiet: true
      }
    )

    result = described_class.call(
      s3_client:,
      bucket_name:,
      blob_scope:,
      dry_run: false,
      db_batch_size: 2,
      delete_only_if_last_modified_before: Time.zone.parse('2026-05-13 09:00:00 UTC'),
      logger:
    )

    expect(result.scanned_objects_count).to eq(2)
    expect(result.orphaned_objects_count).to eq(1)
    expect(result.deleted_objects_count).to eq(1)
  end

  it 'rejects unsupported environments' do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

    expect do
      described_class.call(
        s3_client:,
        bucket_name:,
        blob_scope:,
        logger:
      )
    end.to raise_error(
      RuntimeError,
      'ActiveStorage::StagingBucketCleanup only supports staging'
    )
  end
end
