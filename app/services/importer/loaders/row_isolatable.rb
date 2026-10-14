# Retry-and-isolate mechanism shared by exactly the two raw_* loaders (RawInsertAll,
# RawUpsertAll) - PlainRecord never needs this since every row there is already its own
# individually-attributable create!/save!, and ActiverecordImport handles its own
# failure attribution via failed_instances. Included only by those two loader classes.
#
# ImportError is referenced below as Importer::Base::ImportError, fully qualified: a
# bare constant here would resolve via this module's own lexical nesting
# (Importer::Loaders), which doesn't have it - not the ancestry of whatever includes it.
module Importer::Loaders::RowIsolatable
  private

  # Try the whole batch as one statement; on failure, retry one row at a time purely to
  # identify and log which line(s) caused it, then re-raise - still fail-all, just
  # legible. `writer` is the one thing that differs per mode.
  def write_batch_with_row_isolation(batch, &writer)
    # target_model's own connection, not ActiveRecord::Base's - see base.rb#import!.
    #
    # Runs in its own savepoint deliberately: a failure needs a real ROLLBACK TO
    # SAVEPOINT, not just a Ruby rescue, or Postgres leaves the connection aborted and
    # every retry below fails regardless of whether that row is actually fine.
    @target_model.transaction(requires_new: true) do
      writer.call(batch.pluck(:attrs))
    end

    # Resolves :primary_key_value by value, not RETURNING row order - see
    # Importer::Loaders::Base#resolve_primary_key_values! and FINDINGS.md.
    resolve_primary_key_values!(batch)
  rescue ActiveRecord::StatementInvalid => e
    # A DB-level failure applies to the whole batch's single SQL statement - Postgres
    # has no "skip just the bad row," so there's no way to tell which row it was here.
    failed_lines = isolate_failing_rows(batch, &writer)

    raise Importer::Base::ImportError, "Row write failed for line(s) #{failed_lines.join(', ')}: #{e.message}"
  end

  def isolate_failing_rows(batch, &writer)
    batch.filter_map do |item|
      @target_model.transaction(requires_new: true) do
        writer.call([ item[:attrs] ])
      end
      nil
    rescue ActiveRecord::StatementInvalid => e
      @logger.error(row: item[:line_number], message: e.message)
      item[:line_number]
    end
  end
end
