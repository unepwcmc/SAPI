# See README.md's Modes section (parent directory) for what :activerecord_import does
# and doesn't support.
class Importer::Loaders::ActiverecordImport < Importer::Loaders::Base
  def self.primary_key_lookup_mode? = true
  def self.supports_on_failure_skip? = true

  def initialize(...)
    super

    assert_updatable_columns!
    assert_upsert_supported!
  end

  # One call to the gem's `import` per batch - one bulk INSERT, real model instances so
  # validations run, but real columns only (no virtual/writer-method attributes - see
  # README.md) and model callbacks do NOT fire (inherent to any multi-row bulk INSERT).
  #
  # validate: true is what makes failed_instances possible: invalid records are filtered
  # out before the INSERT runs instead of hitting a DB-level error.
  #
  # assert_no_duplicate_unique_by_values! only runs when unique_by is declared here
  # (unlike :raw_upsert_all, unconditional) - unique_by is optional for this mode, and
  # with no conflict target there's no ON CONFLICT for two same-batch rows to collide on.
  def write_batch(batch)
    original_size = batch.size

    # Same pre-batch existence check as raw_upsert_all (one bulk statement, no per-row
    # lookup). No partition_by_primary_key_presence equivalent needed: Model.import
    # builds each INSERT from the instance's own attributes, so mixing id-set/unset
    # instances already works.
    batch = reject_missing_primary_key_rows!(batch) if primary_key_protected_lookup?
    missing_pk_skipped = original_size - batch.size

    return { written: 0, skipped: missing_pk_skipped } if batch.empty?

    assert_no_duplicate_unique_by_values!(batch) unless @unique_by_config.columns.empty?

    records = batch.map { |item| @target_model.new(item[:attrs]) }
    line_numbers = batch.pluck(:line_number)
    result = nil

    begin
      # target_model's own connection, not ActiveRecord::Base's - see base.rb#import!.
      @target_model.transaction(requires_new: true) do
        result = @target_model.import(records, validate: true, **activerecord_import_upsert_option)
      end
    rescue ActiveRecord::StatementInvalid => e
      # A DB-level failure (unlike a validation failure) applies to the whole batch's
      # one bulk INSERT, with no way to tell which row caused it - unlike the raw_*
      # loaders' row-by-row retry, that doesn't compose with failed_instances-based skip
      # handling, so this always aborts and rolls back the whole run regardless of
      # on_failure. Deliberate, see README.md.
      raise Importer::Base::ImportError,
        "Batch write failed for line(s) #{line_numbers.first}-#{line_numbers.last}: #{e.message}"
    end

    handle_activerecord_import_failures(result.failed_instances, records, batch)
    resolve_primary_key_values!(written_batch_items(records, batch, result.failed_instances))

    {
      written: batch.size - result.failed_instances.size,
      skipped: missing_pk_skipped + result.failed_instances.size
    }
  end

  private

  # activerecord_import's on_duplicate_key_update needs at least one non-unique_by
  # column to put in its UPDATE SET clause - an empty columns: list makes it silently
  # no-op on conflict instead of erroring (see FINDINGS.md).
  #
  # written_attributes, not required_headers.values: a derived attribute is updated on
  # conflict exactly like a mapped one.
  def assert_updatable_columns!
    return if @unique_by_config.columns.empty?

    update_columns = @written_attributes.map(&:to_sym) - @unique_by_config.columns

    return if update_columns.any?

    raise ArgumentError,
      "#{@importer_class}: activerecord_import with unique_by declared needs at least one other " \
      'written column to update on conflict - this importer writes nothing but the unique_by ' \
      'column(s) themselves, so a conflicting row would otherwise silently keep its old ' \
      'values with no error at all'
  end

  # activerecord-import's MySQL/MariaDB adapter extension never actually gets mixed into
  # the connection class under this app's installed gem versions - a gem defect (see
  # FINDINGS.md), not fixable from this side. Blocks only the upsert path, at config
  # time, rather than a confusing raw Mysql2::Error at the first real conflict; a plain
  # insert via this mode still works regardless of adapter.
  def assert_upsert_supported!
    return if @unique_by_config.columns.empty?

    connection = @target_model.connection
    return if connection.supports_on_duplicate_key_update?

    raise ArgumentError,
      "#{@importer_class}: activerecord_import with unique_by declared needs the connected " \
      'database to support an upsert the installed activerecord-import gem can build - ' \
      "#{connection.adapter_name} does not (a known gem limitation, not something this " \
      'class can work around). Use :activerecord mode instead, which resolves conflicts ' \
      'correctly regardless of adapter.'
  end

  # The gem backfills each written record's id via positional RETURNING matching
  # (import.rb's set_attributes_and_mark_clean) - the same risk the value-based resolver
  # avoids, so that backfill is never read here. This only identifies which batch items
  # were actually written (by object identity) and hands them to the same resolver
  # every raw_* loader uses.
  def written_batch_items(records, batch, failed_instances)
    failed_object_ids = failed_instances.to_set(&:object_id)

    records.each_with_index.filter_map { |record, index| batch[index] unless failed_object_ids.include?(record.object_id) }
  end

  # Every failed instance is logged regardless of on_failure. Matched back to its batch
  # item by object identity (`equal?`), not by value - two rows can share identical
  # attrs (e.g. blank-ish rows), so value-matching could attribute a failure to the
  # wrong line.
  def handle_activerecord_import_failures(failed_instances, records, batch)
    return if failed_instances.empty?

    failed_instances.each do |failed_record|
      item = batch[records.index { |record| record.equal?(failed_record) }]
      message = failed_record.errors.full_messages.join(', ')

      @logger.error(row: item[:line_number], message: message)
      @host.send(:on_row_skip, line_number: item[:line_number], attrs: item[:attrs], message: message) if @on_failure == :skip
    end

    return if @on_failure == :skip

    failed_lines = failed_instances.map { |failed_record| batch[records.index { |record| record.equal?(failed_record) }][:line_number] }

    raise Importer::Base::ImportError, "Row validation failed for line(s) #{failed_lines.join(', ')}"
  end

  # Every written attribute is a real column for this mode, so update_columns needs no
  # filtering beyond the conflict target itself. written_attributes (not
  # required_headers.values) keeps derived attributes updated on conflict too.
  #
  # `on_duplicate_key_update`'s shape differs by adapter: PostgreSQL/SQLite expect
  # `{conflict_target:, columns:}`; MySQL/MariaDB expect a plain column Array, since
  # `ON DUPLICATE KEY UPDATE` isn't scoped to an index the way `ON CONFLICT` is. The
  # wrong shape silently produces no working update clause on MySQL.
  #
  # `connection.supports_insert_conflict_target?` is the discriminator, not an
  # adapter-name string match - this app's own primary connection reports adapter_name
  # "PostGIS", not "PostgreSQL".
  #
  # `index_predicate:` is threaded through only on the Postgres/SQLite branch: when
  # unique_by resolves to a partial index, `ON CONFLICT` must name the index's own
  # predicate too, or Postgres rejects it ("no unique or exclusion constraint matching").
  # `.compact` drops the key when unique_by isn't partial.
  def activerecord_import_upsert_option
    return {} if @unique_by_config.columns.empty?

    update_columns = @written_attributes.map(&:to_sym) - @unique_by_config.columns

    on_duplicate_key_update =
      if @target_model.connection.supports_insert_conflict_target?
        { conflict_target: @unique_by_config.columns, columns: update_columns, index_predicate: @unique_by_config.index_predicate }.compact
      else
        update_columns
      end

    { on_duplicate_key_update: on_duplicate_key_update }
  end
end
