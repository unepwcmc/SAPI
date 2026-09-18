# See README.md's Modes section (parent directory) for what :raw_insert_all does and
# doesn't support.
class Importer::Loaders::RawInsertAll < Importer::Loaders::Base
  include Importer::Loaders::RowIsolatable

  def write_batch(batch)
    # insert_all! requires every hash in one call to share the same keys, and a
    # blank-primary-key row's key is omitted by Importer::RowTransformer - so a mapped
    # primary key needs each presence/absence group written separately.
    partition_by_primary_key_presence(batch).each do |sub_batch|
      write_batch_with_row_isolation(sub_batch) { |attrs| insert_all_attrs(attrs) }
    end

    { written: batch.size, skipped: 0 }
  end

  private

  def insert_all_attrs(attrs)
    # Skipping validations/callbacks is this mode's whole point; values already ran
    # through resolve_cast, this mode's substitute validation layer.
    #
    # insert_all! (not insert_all): plain insert_all hardcodes `on_duplicate: :skip`,
    # silently dropping conflicting rows via `ON CONFLICT DO NOTHING` - which would
    # break this mode's fail-all guarantee. insert_all! hardcodes `on_duplicate: :raise`.
    # rubocop:disable Rails/SkipsModelValidations
    @target_model.insert_all!(attrs)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
