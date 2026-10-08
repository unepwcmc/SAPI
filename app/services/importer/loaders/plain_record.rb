# See README.md's Modes section (parent directory) for what :activerecord does and
# doesn't support.
#
# Named PlainRecord, not ActiveRecord: naming this class ActiveRecord would shadow the
# real ActiveRecord constant for every bare reference in its own methods (a bare
# constant resolves via its own lexical nesting, not the ancestry of what it's
# `include`d/inherited into/from). Importer::Base.mode is still :activerecord; only
# this class's own name differs from it.
class Importer::Loaders::PlainRecord < Importer::Loaders::Base
  def self.supports_virtual_attributes? = true
  def self.primary_key_lookup_mode? = true
  def self.supports_on_failure_skip? = true

  # Unlike the raw_* loaders, this one never needs row-isolation's retry-and-isolate
  # dance - every row is already its own individually-attributable create!/save!.
  def write_batch(batch)
    written = 0
    skipped = 0

    batch.each do |item|
      case write_row_activerecord(item)
      when :written then written += 1
      when :skipped then skipped += 1
      end
    end

    { written:, skipped: }
  end

  private

  # Each row's save runs in its own savepoint regardless of on_failure - for :skip this
  # is essential: a DB-level failure (not just a validation failure) would otherwise
  # leave the connection aborted, poisoning every row after it.
  def write_row_activerecord(item)
    record = build_activerecord_record(item[:attrs])

    # item[:attrs].key?(...), not record.new_record? alone: a blank source primary key
    # also leaves new_record? true, but build_activerecord_record never even attempted
    # a lookup for it - that's not a claim about an existing row.
    if primary_key_protected_lookup? && record.new_record? && item[:attrs].key?(primary_key_attribute)
      return handle_row_failure(
        item,
        "no existing #{@target_model} found for #{primary_key_attribute}: " \
        "#{item[:attrs][primary_key_attribute].inspect}, and allow_primary_key_write is false"
      )
    end

    # target_model's own connection, not ActiveRecord::Base's - see base.rb#import!.
    @target_model.transaction(requires_new: true) { record.save! }

    # primary_key_attribute can be nil for a model with no primary key column.
    item[:primary_key_value] = record.public_send(primary_key_attribute) if primary_key_attribute
    :written
  rescue ActiveRecord::RecordInvalid => e
    handle_row_failure(item, e.record.errors.full_messages.join(', '))
  rescue ActiveRecord::StatementInvalid => e
    handle_row_failure(item, e.message)
  end

  def handle_row_failure(item, message)
    @logger.error(row: item[:line_number], message: message)

    if @on_failure == :skip
      @host.send(:on_row_skip, line_number: item[:line_number], attrs: item[:attrs], message: message)
      :skipped
    else
      raise Importer::Base::ImportError, "Line #{item[:line_number]}: #{message}"
    end
  end

  # unique_by is optional here (required for raw_upsert_all): if declared, find by the
  # natural key and update; otherwise always build a new record.
  #
  # Two guards below are load-bearing, not defensive style:
  # - An empty lookup Hash (unique_by is the primary key and this row's was blank) would
  #   run `find_or_initialize_by({})` with no WHERE conditions, matching an arbitrary
  #   row instead of inserting a new one.
  # - A nil value in an otherwise non-empty lookup, under an ordinary (nulls-distinct)
  #   unique index, would run a well-formed `WHERE col IS NULL` and match an arbitrary
  #   existing NULL row - Postgres itself never treats two NULLs as a conflict there, so
  #   two source rows with a blank key would wrongly overwrite the same row instead of
  #   each getting their own. Skipped only for the ordinary case: a `NULLS NOT DISTINCT`
  #   index can have at most one existing NULL row, so the lookup is correct there.
  #
  # Scoped by the unique index's own predicate when it's partial - unique_by's guarantee
  # only holds for rows matching that index's predicate (e.g. this app's
  # `users.webauthn_id` index, `where: "webauthn_id IS NOT NULL"`), so an unscoped
  # find_or_initialize_by could match a row the index was never scoped to cover.
  # `.where(raw_sql_string)` only narrows the SELECT - it doesn't leak into a
  # not-found record's default attributes the way a Hash `.where` would.
  def build_activerecord_record(attrs)
    return @target_model.new(attrs) if @unique_by_config.columns.empty?

    lookup = attrs.slice(*@unique_by_config.columns)
    return @target_model.new(attrs) if lookup.empty?
    return @target_model.new(attrs) if !@unique_by_config.nulls_not_distinct && lookup.any? { |_, value| value.nil? }

    scope = @unique_by_config.index_predicate ? @target_model.where(@unique_by_config.index_predicate) : @target_model
    record = scope.find_or_initialize_by(lookup)
    record.assign_attributes(attrs)
    record
  end
end
