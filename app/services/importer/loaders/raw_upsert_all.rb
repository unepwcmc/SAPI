# See README.md's Modes section (parent directory) for what :raw_upsert_all does and
# doesn't support.
class Importer::Loaders::RawUpsertAll < Importer::Loaders::Base
  include Importer::Loaders::RowIsolatable

  def self.primary_key_lookup_mode? = true
  def self.trusts_attrs_primary_key_unconditionally? = false

  def write_batch(batch)
    original_size = batch.size
    batch = reject_missing_primary_key_rows!(batch) if primary_key_protected_lookup?

    unless batch.empty?
      assert_no_duplicate_unique_by_values!(batch)
      partition_by_primary_key_presence(batch).each do |sub_batch|
        write_batch_with_row_isolation(sub_batch) { |attrs| upsert_all_attrs(attrs) }
      end
    end

    { written: batch.size, skipped: original_size - batch.size }
  end

  private

  def upsert_all_attrs(attrs)
    # upsert_all's default (on_duplicate: :update) only resolves conflicts against the
    # declared unique_by target - anything else (a NOT NULL violation, etc.) still
    # raises ActiveRecord::StatementInvalid normally, caught the same way as
    # raw_insert_all.
    #
    # on_duplicate is hardcoded to :update, not exposed: :skip would silently drop
    # conflicting rows, the exact problem insert_all! avoids for the other raw mode.
    # update_only/returning/record_timestamps aren't exposed either - nothing has
    # needed them yet.
    # rubocop:disable Rails/SkipsModelValidations
    @target_model.upsert_all(attrs, on_duplicate: :update, unique_by: @unique_by)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
