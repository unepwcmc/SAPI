# Abstract base for every write strategy (RawInsertAll, RawUpsertAll, PlainRecord,
# ActiverecordImport) - constructed once per Importer::Base#import! run, holds the
# per-run state and shared machinery every concrete loader needs: primary-key write
# protection, the same-batch unique_by duplicate guard, and primary-key-value
# resolution. Concrete subclasses implement #write_batch(batch), returning
# {written:, skipped:} - Importer::Base accumulates those into its own counts rather
# than a loader mutating Base's ivars directly.
#
# `importer_class:`/`host:`/`logger:` are the one deliberate backreference to
# Importer::Base a loader needs: `importer_class` only for error messages (matching
# what `#{self.class}` produced when this logic ran as a Base instance method), `host`
# only to call a subclass-overridden hook (`on_row_skip`) via `host.send(...)`, `logger`
# for Importer::Logger#error. Nothing here reads or writes anything else on Base.
#
# ImportError is referenced below as Importer::Base::ImportError, fully qualified: a
# bare constant here would resolve via this module's own lexical nesting
# (Importer::Loaders), which doesn't have it - not the ancestry of Importer::Base.
class Importer::Loaders::Base
  def self.supports_virtual_attributes? = false
  def self.primary_key_lookup_mode? = false
  def self.supports_on_failure_skip? = false
  # False only for RawUpsertAll: Rails' own upsert_all excludes the primary key from its
  # DO UPDATE SET, so a conflicting row keeps its real pre-existing id, not whatever
  # attrs supplied - see resolve_primary_key_values! below.
  def self.trusts_attrs_primary_key_unconditionally? = true

  attr_reader :unique_by_config

  # resolve_primary_keys: whether :primary_key_value is worth resolving at all. It is only
  # ever readable from after_batch - nothing in this class consumes it, and before_batch
  # runs before write_batch populates it - so when nothing is going to read it,
  # resolve_primary_key_values! below would spend a query per batch on a discarded value.
  # Importer::Base decides this (it owns the hooks) and passes the answer down, rather
  # than this class introspecting the host's own class hierarchy - that would make every
  # loader depend on Importer::Concerns::Hooks. Defaults true, so a standalone loader
  # built without an importer behaves as it always did.
  def initialize(importer_class:, target_model:, on_failure:, allow_primary_key_write:, unique_by:, written_attributes:, host:, logger:, resolve_primary_keys: true)
    @resolve_primary_keys = resolve_primary_keys
    @importer_class = importer_class
    @target_model = target_model
    @on_failure = on_failure
    @allow_primary_key_write = allow_primary_key_write
    # The raw declaration, not the resolved column list below - RawUpsertAll passes
    # this straight through to Rails' own upsert_all, which does its own independent
    # resolution (and, notably, accepts an index name directly, unlike our own
    # column-only resolution).
    @unique_by = unique_by
    @written_attributes = written_attributes
    @host = host
    @logger = logger

    @unique_by_config =
      if unique_by.present?
        Importer::Loaders::UniqueByResolver.resolve!(importer_class:, target_model:, unique_by:, written_attributes:)
      else
        Importer::Loaders::UniqueByConfig::NONE
      end
  end

  # Returns {written: Integer, skipped: Integer} - never mutates anything on the host.
  def write_batch(batch)
    raise NotImplementedError
  end

  # allow_primary_key_write true means a caller-supplied primary key never advances
  # Postgres's own SERIAL/IDENTITY sequence (insert_all!/upsert_all/save! all bypass
  # nextval() when a value is supplied) - left unresynced, a later unrelated `create!`
  # can collide with the id this import claimed manually, raising PG::UniqueViolation.
  #
  # `connection.reset_pk_sequence!` resyncs to MAX(id); gated to Postgres via
  # `respond_to?` since MySQL's AUTO_INCREMENT already self-advances and the method
  # doesn't exist there. Safe to call unconditionally when available - a no-op on an
  # empty table or a non-sequence (e.g. UUID) primary key.
  #
  # Called once from Importer::Base#import!, after the run's transaction has committed -
  # reset_pk_sequence! is idempotent, so once per run is enough.
  def reset_pk_sequence!
    return unless @allow_primary_key_write

    connection = @target_model.connection
    return unless connection.respond_to?(:reset_pk_sequence!)

    connection.reset_pk_sequence!(@target_model.table_name)
  end

  # Public, unlike everything below - Importer::Base#build_attributes needs it too, to
  # know which mapped/derived attribute is the primary key (and so should be omitted
  # entirely, not nulled, when its raw value is blank).
  def primary_key_attribute
    @target_model.primary_key&.to_sym
  end

  protected

  # True only when unique_by resolves to exactly the primary key column, on a lookup
  # mode, and allow_primary_key_write hasn't opted out. Any other unique_by is guarded
  # at config time instead (Importer::Base#assert_primary_key_write_protected!).
  def primary_key_protected_lookup?
    return false if @allow_primary_key_write
    return false unless self.class.primary_key_lookup_mode?

    @unique_by_config.columns == [ primary_key_attribute ]
  end

  # Rails' insert_all!/upsert_all require every hash in a call to share the exact same
  # keys (raises ArgumentError otherwise), so rows with vs. without a provided primary
  # key must be split into separate sub-batches. Not needed by activerecord_import:
  # Model.import builds each row's INSERT from its own instance attributes.
  def partition_by_primary_key_presence(batch)
    pk = primary_key_attribute
    return [ batch ] unless pk

    batch.group_by { |item| item[:attrs].key?(pk) }.values
  end

  # Enforces allow_primary_key_write false at runtime for raw_upsert_all/
  # activerecord_import, which write via one bulk statement and can't tell
  # found-vs-not-found before it runs - does a pre-batch SELECT for given ids and
  # filters out (or raises for) any not found.
  def reject_missing_primary_key_rows!(batch)
    pk = primary_key_attribute
    candidates = batch.select { |item| item[:attrs].key?(pk) }

    return batch if candidates.empty?

    ids = candidates.map { |item| item[:attrs][pk] }
    existing_ids = @target_model.where(pk => ids).pluck(pk).to_set
    missing = candidates.reject { |item| existing_ids.include?(item[:attrs][pk]) }

    return batch if missing.empty?

    messages =
      missing.index_with do |item|
        "no existing #{@target_model} found for #{pk}: #{item[:attrs][pk].inspect}, " \
          'and allow_primary_key_write is false'
      end

    missing.each { |item| @logger.error(row: item[:line_number], message: messages[item]) }

    if @on_failure == :skip
      # A third skip path, distinct from Importer::Base's own exclude_row? filtering and
      # each loader's own row/instance-level failure handling - on_row_skip must fire
      # here too. raw_upsert_all also calls this method, but on_failure :skip is never
      # configurable there (Importer::Base#assert_on_failure_supported!), so this branch
      # is only actually reached for activerecord_import.
      missing.each do |item|
        @host.send(:on_row_skip, line_number: item[:line_number], attrs: item[:attrs], message: messages[item])
      end

      batch - missing
    else
      raise Importer::Base::ImportError,
        "Primary key not found for line(s) #{missing.pluck(:line_number).join(', ')} - " \
        'allow_primary_key_write is false'
    end
  end

  # Resolves :primary_key_value (Importer::Concerns::Hooks#after_batch) for a batch of
  # successfully-written items, by value - never by relying on Postgres RETURNING's row
  # order matching input order (undocumented, not guaranteed). activerecord-import's own
  # PK backfill (set_attributes_and_mark_clean) relies on that same positional
  # assumption, so it isn't trusted either. See FINDINGS.md for the full history.
  #
  # Not called from Importer::Loaders::PlainRecord (:activerecord):
  # record.public_send(...) right after that object's own save! is a value read, not a
  # correlation problem.
  #
  # Two ways a row's primary key can be known with certainty, tried in order - anything
  # else is left unresolved rather than guessed:
  # 1. The row's own attrs already included it (allow_primary_key_write true) - except
  #    for raw_upsert_all conflicting on a non-primary-key unique_by: Rails' upsert_all
  #    excludes the primary key from DO UPDATE SET, so a conflicting row keeps its real
  #    pre-existing id, not whatever attrs supplied. Falls through to step 2 for that
  #    case (activerecord_import's own upsert does write a supplied id on conflict, so
  #    it doesn't share this problem; nor does raw_insert_all, which never resolves
  #    conflicts).
  # 2. unique_by is declared - delegates to assign_primary_key_values_by_unique_key!
  #    below (one query per batch, matched back by value). Correct for updates and
  #    inserts alike, since the query runs after the write. raw_upsert_all always has
  #    unique_by.
  # A "blind" bulk insert with no unique_by and no explicit primary key never gets
  # :primary_key_value - a deliberate narrowing, not an oversight.
  def resolve_primary_key_values!(items)
    return unless @resolve_primary_keys

    pk = primary_key_attribute
    return unless pk

    trust_attrs_pk_directly = self.class.trusts_attrs_primary_key_unconditionally? || @unique_by_config.columns == [ pk ]

    remaining = []

    items.each do |item|
      if trust_attrs_pk_directly && item[:attrs].key?(pk)
        item[:primary_key_value] = item[:attrs][pk]
      else
        remaining << item
      end
    end

    return if remaining.empty? || @unique_by_config.columns.empty?

    assign_primary_key_values_by_unique_key!(remaining, pk)
  end

  # Queries by the first unique_by column only (a loose filter, fine even if not unique
  # alone), then matches each candidate back by its full unique_by tuple in Ruby - exact,
  # order-independent.
  #
  # A tuple shared by more than one row (possible with nullable unique_by columns, since
  # Postgres nulls are distinct by default) is left unresolved for every row sharing it -
  # there's no reliable way to tell which id belongs to which row.
  def assign_primary_key_values_by_unique_key!(candidates, pk)
    unique_by_columns = @unique_by_config.columns
    first_column = unique_by_columns.first
    first_values = candidates.map { |item| item[:attrs][first_column] }

    rows = @target_model.where(first_column => first_values).pluck(*unique_by_columns, pk)
    pks_by_value = rows.group_by { |row| row[0...-1] }.transform_values { |grouped| grouped.map(&:last) }

    batch_keys = candidates.map { |item| unique_by_columns.map { |column| item[:attrs][column] } }
    ambiguous_batch_keys = batch_keys.tally.select { |_key, count| count > 1 }.keys.to_set

    candidates.each_with_index do |item, index|
      key = batch_keys[index]
      next if ambiguous_batch_keys.include?(key)

      matches = pks_by_value[key]
      item[:primary_key_value] = matches.first if matches&.size == 1
    end
  end

  # Two rows in the same batch sharing a unique_by value raise PG::CardinalityViolation
  # from the underlying `INSERT ... ON CONFLICT DO UPDATE` - and isolate_failing_rows
  # can't diagnose it, since retrying one row at a time makes the conflict disappear
  # (each retry has only one row). So this is checked proactively in plain Ruby before
  # any write is attempted, which also lets it attribute the failure to specific lines.
  #
  # Only catches duplicates within the same batch - across batches, the second batch's
  # upsert legitimately (and silently) updates what the first batch just inserted.
  #
  # checkable excludes any item missing a unique_by column from attrs (a primary-key
  # column left blank - the DB assigns a fresh value, nothing to conflict on). Whether a
  # present-but-nil value is also excluded depends on nulls_not_distinct: an ordinary
  # Postgres unique index never treats NULL as equal to anything, even another NULL, so
  # same-batch NULLs there don't conflict; a `NULLS NOT DISTINCT` index is the opposite
  # and must be checked like any other value.
  def assert_no_duplicate_unique_by_values!(batch)
    columns = @unique_by_config.columns
    nulls_not_distinct = @unique_by_config.nulls_not_distinct

    checkable =
      batch.select do |item|
        columns.all? do |column|
          next false unless item[:attrs].key?(column)
          next true if nulls_not_distinct

          !item[:attrs][column].nil?
        end
      end
    grouped = checkable.group_by { |item| columns.map { |column| item[:attrs][column] } }
    duplicated_groups = grouped.values.select { |items| items.size > 1 }

    return if duplicated_groups.empty?

    duplicated_groups.each do |items|
      line_numbers = items.map { |item| item[:line_number] }

      items.each do |item|
        other_lines = line_numbers - [ item[:line_number] ]
        @logger.error(
          row: item[:line_number],
          message: "duplicate unique_by value, also on line(s) #{other_lines.join(', ')} in the same batch"
        )
      end
    end

    all_line_numbers = duplicated_groups.flatten.pluck(:line_number).sort

    raise Importer::Base::ImportError,
      "Duplicate unique_by value(s) within the same batch at line(s) #{all_line_numbers.join(', ')} - " \
      'reduce batch_size so these rows fall in different batches, or fix the duplicate in the source file'
  end
end
