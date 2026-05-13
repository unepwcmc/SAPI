require 'spec_helper'

describe ActiveStorage::StagingBucketBackfill do
  let(:s3_client) { instance_double(Aws::S3::Client) }
  let(:logger) { instance_double(ActiveSupport::Logger, info: true, warn: true) }
  let(:blob_scope) { class_double(ActiveStorage::Blob) }
  let(:source_bucket_name) { 'species-plus-production' }
  let(:destination_bucket_name) { 'species-plus-staging' }
  let(:first_relation) { instance_double(ActiveRecord::Relation) }
  let(:second_relation) { instance_double(ActiveRecord::Relation) }
  let(:existing_destination_object) do
    instance_double(Aws::S3::Types::Object, key: 'already-present')
  end
  let(:destination_page_response) do
    instance_double(
      Aws::S3::Types::ListObjectsV2Output,
      contents: [ existing_destination_object ],
      is_truncated: false,
      next_continuation_token: nil
    )
  end

  before do
    allow(blob_scope).to receive(:select).with(:key).and_return(blob_scope)
    allow(blob_scope).to receive(:in_batches).with(of: 2).and_yield(first_relation).and_yield(second_relation)
    allow(first_relation).to receive(:pluck).with(:key).and_return([ 'already-present', 'missing-in-staging' ])
    allow(second_relation).to receive(:pluck).with(:key).and_return([ 'missing-in-production' ])
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('staging'))
    allow(s3_client).to receive(:list_objects_v2).with(
      bucket: destination_bucket_name,
      continuation_token: nil
    ).and_return(destination_page_response)
  end

  it 'lists missing staging keys in dry run mode' do
    result = described_class.call(
      s3_client:,
      source_bucket_name:,
      destination_bucket_name:,
      blob_scope:,
      dry_run: true,
      db_batch_size: 2,
      logger:
    )

    expect(result.scanned_blob_keys_count).to eq(3)
    expect(result.missing_in_staging_count).to eq(2)
    expect(result.copied_objects_count).to eq(0)
    expect(result.missing_in_production_count).to eq(0)
    expect(result.dry_run).to be(true)
  end

  it 'copies only keys missing from staging and reports missing production objects' do
    expect(s3_client).to receive(:copy_object).with(
      bucket: destination_bucket_name,
      key: 'missing-in-staging',
      copy_source: 'species-plus-production/missing-in-staging'
    )
    expect(s3_client).to receive(:copy_object).with(
      bucket: destination_bucket_name,
      key: 'missing-in-production',
      copy_source: 'species-plus-production/missing-in-production'
    ).and_raise(Aws::S3::Errors::NoSuchKey.new(nil, 'missing'))

    result = described_class.call(
      s3_client:,
      source_bucket_name:,
      destination_bucket_name:,
      blob_scope:,
      dry_run: false,
      db_batch_size: 2,
      logger:
    )

    expect(result.scanned_blob_keys_count).to eq(3)
    expect(result.missing_in_staging_count).to eq(2)
    expect(result.copied_objects_count).to eq(1)
    expect(result.missing_in_production_count).to eq(1)
    expect(result.dry_run).to be(false)
  end
end
