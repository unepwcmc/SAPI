# Every subclass-overridable hook Importer::Base offers, other than `cast_<attribute>`
# (dispatched dynamically by column name in Importer::RowTransformer). One home for all
# of them.
#
# before_import/after_import were deliberately dropped: a subclass consumer already
# controls that by wrapping `SomeImporter.new(file_path:).import!` itself. on_row_skip
# and before_batch/after_batch are different: those decisions happen inside import!'s
# own private loop and can't be observed any other way.
#
# Named Hooks, not Callbacks: "callback" already means the model's own ActiveRecord
# callbacks elsewhere in this class.
#
# Row filtering (blank-row dropping, exclude_row? dispatch) used to live here too
# (process_row), called from inside each parser's own streaming loop - moved into
# Importer::Base#import! directly instead, since a parser now yields every row
# unconditionally and knows nothing about business rules (see FINDINGS.md).
#
# Mixed into Importer::Base via `include`; nothing here is meant to be used standalone.
module Importer::Concerns::Hooks
  private

  # Lets a subclass exclude a row before any cast/write, based on a business rule
  # rather than invalid data - e.g. a `Status` column meaning "draft, skip this one".
  # `row` includes every column in the file, not just ones mapped in required_headers.
  # Distinct from on_failure :skip, which is about unusable data, not an unwanted row.
  def exclude_row?(row)
    false
  end

  # Lets a subclass react to a row being skipped as it happens (notify, count, write to
  # a side table) instead of only inspecting #logs after import! returns. Only fires for
  # on_failure :skip on :activerecord/:activerecord_import (raw_* modes reject :skip at
  # config time) - never for :rollback, which raises immediately instead. An override
  # that raises propagates and rolls back the run like any other in-batch failure.
  def on_row_skip(line_number:, attrs:, message:)
  end

  # Lets a subclass observe a batch about to be written - e.g. progress reporting a
  # caller can't get from #logs until the whole run finishes. `batch` is the same
  # `[{line_number:, attrs:, row:}]` Array write_batch itself receives. Never called
  # for an empty batch.
  def before_batch(batch)
  end

  # The after_batch counterpart to before_batch - same batch, same empty-batch guard,
  # called once write_batch has returned successfully for it (an exception there
  # propagates directly, skipping this).
  #
  # Each item also carries :row, the raw row Hash exclude_row? saw - not just the
  # mapped :attrs - useful when a single cell (e.g. a CSV list column) needs to be
  # written to a separate join table once the batch's own foreign key is known.
  #
  # :primary_key_value is the real, resolved primary key each row was written as (not
  # necessarily anything the source file provided) - resolved by value, never by
  # RETURNING row position, which is not a documented PostgreSQL guarantee (see
  # Importer::Loaders::Base#resolve_primary_key_values! and FINDINGS.md). Populated only when
  # the row's attrs already included the primary key, or unique_by resolved it via one
  # extra query per batch; not populated for a "blind" insert with neither, or when two
  # rows in a batch share the same unique_by value.
  #
  # Only :activerecord/:activerecord_import can mix a written row and an on_failure
  # :skip row in the same batch; raw_* batches are always written in full.
  def after_batch(batch)
  end
end
