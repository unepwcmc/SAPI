# Resolves a `unique_by` declaration against target_model's real indexes into a
# Importer::Loaders::UniqueByConfig - pure function, no host/logger/ivar dependency, so
# it's usable standalone.
#
# Mirrors Rails' own resolution in ActiveRecord::InsertAll#find_unique_index_for:
# unique_by matches an index either by name or by column set, not columns only -
# `unique_by :index_widgets_on_name` is just as valid as `unique_by :name`.
module Importer::Loaders::UniqueByResolver
  def self.resolve!(importer_class:, target_model:, unique_by:, written_attributes:)
    match = Array(unique_by).map(&:to_s)
    pk = target_model.primary_key

    # A primary key's own index never appears in connection.indexes - Postgres
    # represents it as a constraint, not an index Rails' introspection lists - so
    # `unique_by :id` is resolved directly here instead of searching a list that would
    # never contain it.
    if match == [ pk ]
      # A primary key column can never be NULL and its constraint is never partial, so
      # neither nulls_not_distinct nor an index predicate ever applies here.
      unique_by_columns = [ pk ]
      nulls_not_distinct = false
      index_predicate = nil
    else
      sorted_match = match.sort
      indexes = target_model.connection.indexes(target_model.table_name)
      index = indexes.find { |idx| idx.unique && (match.include?(idx.name) || idx.columns.sort == sorted_match) }

      unless index
        raise ArgumentError,
          "#{importer_class}: no unique index found on #{target_model} for unique_by: #{unique_by.inspect}"
      end

      # A Postgres 15+ `UNIQUE NULLS NOT DISTINCT` index treats two NULLs as a conflict,
      # unlike the ordinary `NULLS DISTINCT` default - the same-batch duplicate guard
      # needs to know which kind of index it's enforcing against.
      nulls_not_distinct = index.nulls_not_distinct

      # A partial index's own predicate (e.g. `where: "webauthn_id IS NOT NULL"`) - the
      # uniqueness this index enforces only applies to a row matching this predicate.
      # PlainRecord scopes its lookup by it; ActiverecordImport passes it through as
      # activerecord-import's own `index_predicate:` option so its ON CONFLICT clause
      # actually matches this index. :raw_upsert_all needs no equivalent fix - Rails'
      # own upsert_all already appends it via ActiveRecord::InsertAll#conflict_target.
      index_predicate = index.where
      unique_by_columns = index.columns
    end

    # For raw_upsert_all, if the conflict-target column(s) aren't in required_headers,
    # upsert_all doesn't raise or warn - it silently writes NULL (or the default) for
    # that column on every row, so nothing ever conflicts and every "upsert" quietly
    # becomes a plain insert. The activerecord-mode equivalent is just as silently
    # useless. Caught here since nothing downstream ever would.
    unwritten = unique_by_columns - written_attributes.map(&:to_s)

    if unwritten.any?
      raise ArgumentError,
        "#{importer_class}: unique_by column(s) #{unwritten.join(', ')} must be mapped in " \
        'required_headers or declared in derived_attributes, or there is nothing to detect ' \
        'an existing record by and every row is silently treated as new'
    end

    # Frozen, like UniqueByConfig::NONE: this is resolved once at loader construction and
    # only ever read afterwards, and the surrounding design leans on that ("constructing
    # the loader *is* resolve-and-validate" - see FINDINGS.md).
    Importer::Loaders::UniqueByConfig.new(
      columns: unique_by_columns.map(&:to_sym).freeze, nulls_not_distinct:, index_predicate:
    ).freeze
  end
end
