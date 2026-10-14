# Importer - Development Findings

Reference material, not a usage guide - what was actually tested, what broke, and the
exact results, for whoever touches this code next. See [README.md](README.md) for how to
use the class, and [REQUIREMENTS.md](REQUIREMENTS.md) for the rules themselves without
the evidence behind them.

## CSV / general modes - things that looked right but weren't

Several design decisions only work correctly because of specific, non-obvious behavior
in Rails/Postgres/Ruby's CSV library that isn't visible just from reading the happy
path. Each of these was found by empirically testing against a real Postgres connection
or a real file, not by reasoning about it in the abstract:

- **Rails' own type casters are silently lossy.** `ActiveModel::Type::Integer`/`Decimal`/
  `Date`/`Boolean` don't raise on invalid input - a non-numeric string cast to an integer
  or decimal column silently becomes `0`; an unparseable date silently becomes `NULL`;
  a boolean token like `"N"` (not in Rails' fixed false-value list) silently becomes
  `true`. This is true of plain attribute assignment too, not just `insert_all`. It's why
  every column goes through a strict cast step at all, rather than trusting Rails' own
  casting.
- **`default_cast`'s catch-all `else raw_value` branch was itself a silent-passthrough
  gap in the same spirit as the one above - identified in discussion with the user, not
  found as a live bug.** Mapping a column of a type this class has no explicit parser
  for (`:json`/`:jsonb`, an array or enum column, a PostGIS geometry column - this app
  depends on `activerecord-postgis-adapter`) produced no error at all: the raw value
  passed straight through to Rails' own casting downstream, unvalidated - exactly the
  silently-lossy failure mode the rest of this pipeline exists to prevent, just for a
  type outside the covered set rather than bad input within it. Fixed by raising for any
  type not explicitly handled, with `:string`/`:text` added as their own explicit
  (no-op) cases first, so they aren't caught by the new raise. `cast_<attribute>` is the
  intended escape hatch for a subclass that genuinely needs one of the unsupported
  types. One case is deliberately excluded from the new raise: `type_for_attribute`
  returns a `nil` type - not an actual type symbol - specifically for a
  virtual/writer-method attribute (verified directly: `nil` for a non-existent/virtual
  attribute name, versus the real type symbol, e.g. `:jsonb`, for an actual column of an
  unsupported type) - a virtual attribute was always out of scope for this cast
  pipeline, so it still receives its raw value completely untouched, same as before this
  change; only a *real* column of an unhandled type now raises.
- **A `:datetime` column silently lost its time-of-day until this was fixed - found by
  an external review, not caught by this project's own testing at the time.**
  `default_cast`'s `:date`/`:datetime` branch originally shared one parser, `parse_date`
  (`Date.parse`), for both. Verified directly: `Date.parse("2026-07-25 15:30:45")`
  returns just `Sat, 25 Jul 2026` - no error, no warning - and persisting that `Date` to
  a real `:datetime` column stores it at `00:00:00`, silently discarding the actual time.
  Fixed with a separate `parse_datetime` for the `:datetime` case, using `DateTime.parse`
  - deliberately not `Time.zone.parse`, verified directly that `Time.zone.parse` returns
  `nil` (not an error) for genuinely unparseable input, which is exactly the kind of
  silent data loss this whole cast pipeline exists to prevent; `DateTime.parse` raises
  `Date::Error` instead (confirmed a subclass of `ArgumentError`, so the existing
  `rescue ArgumentError` catches it with no other change needed).
- **`activerecord_import`'s upsert path raised `PG::UndefinedColumn` for a virtual/
  writer-method attribute combined with `unique_by` - found by an external review, not
  this project's own testing at the time.** `activerecord_import_upsert_option` built
  `on_duplicate_key_update`'s `columns:` list from every `required_headers`-mapped
  attribute, including a virtual one (this mode explicitly allows a hand-written writer
  method in `required_headers`, unlike the raw_* modes) - but the gem builds a raw
  `SET "attr" = EXCLUDED."attr"` clause for every entry in `columns`, and there's no real
  column for either side of that assignment to reference for a virtual attribute.
  Reproduced directly: `PG::UndefinedColumn: column excluded.custom_virtual does not
  exist`. Fixed by intersecting with `target_model.column_names` before building
  `update_columns`. This is a real, permanent limitation of the mode, not just a crash
  fix: a virtual attribute's writer method is Ruby code that only ever runs when
  `.new(attrs)` builds a record in memory, before the bulk statement - the `ON CONFLICT
  DO UPDATE` branch is Postgres updating an existing row directly, with no model
  instantiated at all, so a virtual attribute (and whatever real column its writer
  indirectly sets) is only ever applied on insert for this mode, never refreshed on
  conflict/update. Verified directly: after the fix, an insert applies the virtual
  writer's effect correctly, and a subsequent conflicting row updates without error but
  leaves the previously-set value untouched.
  **That fix itself left a further, worse gap when `update_columns` ends up completely
  empty - found by a second external review, not this project's own testing at the
  time.** If every `required_headers`-mapped attribute besides `unique_by` is virtual,
  `update_columns` (after the real-columns intersection above) is `[]`. Passing an
  empty `columns:` to the gem's `on_duplicate_key_update` doesn't raise or no-op
  gracefully - verified directly that it makes a conflicting row's `UPDATE` touch
  nothing at all, with `result.failed_instances` empty and no exception raised.
  Reproduced through the full import pipeline: a second import with a changed
  virtual-attribute value left the target row's real column completely unchanged, and
  `#logs` reported an entirely ordinary `"import completed"` summary - no error, no
  entry, nothing to indicate anything was silently dropped. Unlike the first gap
  (narrowly about the virtual attribute itself never being refreshed), this one is
  total: with no real column left to update at all, a conflicting row's `UPDATE`
  effectively does nothing, and there is no per-row signal that this happened.
  Since this is true for *every* conflicting row such a subclass could ever hit - not
  something that depends on any one row's data - it's caught at config time instead of
  left as a runtime surprise: `assert_updatable_columns!`
  (`Importer::Loaders::ActiverecordImport`, run from its own constructor) raises
  `ArgumentError` up front whenever
  `unique_by` is declared for `:activerecord_import` and no real, non-`unique_by`
  column would be left in `update_columns`.
  **Decided afterward to remove virtual/writer-method attribute support from this mode
  entirely, rather than keep patching around it.** Two separate bugs in a row, both
  specifically about the interaction between a virtual attribute and this mode's
  conflict-handling, was a strong enough signal that the feature was structurally
  fragile here - not a coincidence of two isolated oversights. The underlying reason
  neither bug is fixable in a way that makes the *feature* fully safe: a virtual
  attribute's writer method is Ruby code that can only ever run when `.new(attrs)`
  builds a record in memory (at insert time) - `ON CONFLICT DO UPDATE` is Postgres
  updating an existing row directly, with no model ever instantiated for that row, so
  there's no way for it to run there regardless of how the `columns:` list is
  computed. `activerecord_import` now requires real columns only, exactly like the
  raw_* modes (`supports_virtual_attributes?` is true only on
  `Importer::Loaders::PlainRecord`) - `activerecord_import_upsert_option` no longer needs to
  intersect `required_headers` against `target_model.column_names` at all, since every
  mapped attribute is now guaranteed to already be one.
- **An unrecognized `on_failure` value was silently accepted for a model-backed mode,
  behaving exactly like `:rollback` with no config-time error at all - found by an
  external review, not this project's own testing at the time.**
  `assert_on_failure_supported!` only ever checked "is this `:rollback`?" and "is this
  mode model-backed?", never "is this actually one of the two values `on_failure`
  understands?" - so `on_failure :typo` on `:activerecord`/`:activerecord_import` passed
  straight through: the first `return` didn't fire (`:typo != :rollback`), and the
  second one did (the mode is model-backed), so the method returned having checked
  nothing about the value at all. Every runtime check downstream
  (`handle_row_failure`/`handle_activerecord_import_failures`) only ever tests
  `on_failure == :skip`, so `:typo` silently fell through to the same raise-and-rollback
  behavior as `:rollback` - inconsistent with the documented `:rollback | :skip`
  contract, with nothing at config time to say so. The same bad value on a raw mode
  did still raise before this fix, but with a misleading message
  ("`on_failure :skip` is not supported") that didn't reflect what was actually wrong.
  Fixed with an explicit allowed-values check (`SUPPORTED_ON_FAILURE_VALUES`) ahead of
  the existing per-mode restriction; verified directly that a bad value now raises a
  clear error for both a model-backed and a raw mode, while `:rollback` and (where
  supported) `:skip` still behave exactly as before.
- **Plain `insert_all` silently skips conflicting rows.** It hardcodes
  `on_duplicate: :skip` internally (`ON CONFLICT DO NOTHING`) and never raises on a
  duplicate-key conflict - confirmed by reading Rails' own source, not assumed.
  `insert_all!` (`on_duplicate: :raise`) is what `raw_insert_all` actually uses, or a
  duplicate row would vanish with no error and no log entry. `upsert_all` has no bang
  equivalent, but doesn't need one - verified empirically that its default
  (`on_duplicate: :update`) only resolves conflicts against the declared `unique_by`
  target; anything else (a `NOT NULL` violation, a conflict on some other constraint)
  still raises `ActiveRecord::StatementInvalid` normally, so `raw_upsert_all` catches it
  the same way `raw_insert_all` does, with no equivalent trap to route around.
- **A failed batch statement can poison the connection for whatever runs next.** Once
  Postgres hits an error inside a transaction, it refuses every further command
  ("current transaction is aborted") until a rollback happens - including a `SAVEPOINT`.
  So `isolate_failing_rows`'s row-by-row retry only works because the *initial* failing
  bulk attempt (`write_batch_with_row_isolation`) is wrapped in its own
  `requires_new: true` savepoint first; without that, every row in the retry loop comes
  back looking like it failed too, even the ones that are actually fine. This logic is
  now shared between `raw_insert_all` and `raw_upsert_all` (parameterized by a `writer`
  block), not duplicated per mode.
- **`unique_by` naming a real unique index isn't enough - its column(s) also have to be
  in `required_headers`, or `upsert_all` silently does nothing useful.** Verified
  empirically: if the conflict-target column isn't among the mapped attributes,
  `upsert_all` doesn't raise - it just writes `NULL` (or the column's default) for that
  column on every row, so nothing ever matches an existing row and every "upsert"
  quietly becomes a plain insert. `assert_unique_by_valid!` resolves `unique_by` to
  its actual column(s) (whether declared by column name(s) or by index name) and checks
  they're all mapped, specifically because this doesn't fail anywhere else on its own.
- **Two rows sharing a `unique_by` value in the *same* batch break `isolate_failing_rows`
  entirely - it can diagnose everything else, but not this.** Verified empirically:
  Postgres raises `PG::CardinalityViolation` ("ON CONFLICT DO UPDATE command cannot
  affect row a second time") for this case, which sounds like exactly the kind of
  DB-level failure `isolate_failing_rows` retries row-by-row to attribute. But retrying
  one row at a time is precisely what makes the problem vanish - with only one row per
  statement, there's nothing left for it to conflict with, so *both* rows individually
  succeed on retry, `#logs` stays empty, and the re-raised message shows an empty line
  list (`"Row write failed for line(s) : ..."`). So this is caught proactively instead
  (`assert_no_duplicate_unique_by_values!`), in plain Ruby, grouping the batch by
  `unique_by` value before any write is attempted - cheaper than a DB round-trip, and it
  can actually name the offending lines, which the retry-based path structurally cannot.

  This only covers duplicates within one batch. Two rows sharing a `unique_by` value
  across *different* batches don't raise at all: the second batch's upsert legitimately
  updates the row the first batch's upsert just inserted, silently, with no log entry,
  since nothing about that looks like a failure to Postgres or to us. So the exact same
  source-file mistake (a repeated natural key) either crashes loudly with a clear message
  or silently resolves as last-one-wins, depending entirely on `batch_size` and where in
  the file the duplicate rows happen to fall - not on anything about the data itself.
  Worth knowing; not something this class can (or should try to) paper over across batch
  boundaries, since "the last row wins" is genuinely correct upsert behavior when the
  rows are far enough apart to land in separate statements.

  This turned out not to be `raw_upsert_all`-specific: `activerecord_import`'s upsert
  path issues the same underlying `INSERT ... ON CONFLICT DO UPDATE` once
  `on_duplicate_key_update` is in play, and reproduces the identical
  `PG::CardinalityViolation` for a same-batch duplicate, found by testing it directly
  rather than assuming the two write paths would diverge. `assert_no_duplicate_unique_by_values!`
  is shared between both now (`Importer::Loaders::Base`), not duplicated -
  `activerecord_import` only runs it when `unique_by` is actually declared there (it's
  optional for that mode, unlike `raw_upsert_all` where it's required), since with no
  conflict target there's no `ON CONFLICT` clause for two same-batch rows to collide on
  in the first place.
- **This same-batch guard had a false-positive gap for a *nullable* `unique_by` column -
  found by an external review, not this project's own testing at the time.** Postgres'
  ordinary (default) unique index never treats a `NULL` as equal to anything for its
  own conflict detection, including another `NULL` - verified directly:
  `upsert_all([{col: nil}, {col: nil}], unique_by: :col)` inserts both rows with no
  conflict at all, and the same holds for a composite key where just one column is
  `nil`, even if every other column matches (`unique_by: [:col_a, :col_b]` with
  `col_a: "x", col_b: nil` on both rows also inserts both, unconditionally). But
  `assert_no_duplicate_unique_by_values!` grouped rows by their raw `unique_by` value(s)
  regardless of nullness, so two unrelated fresh rows that both legitimately left a
  nullable natural key blank were grouped under `[nil]` and flagged as "duplicate", even
  though Postgres itself would never see them as conflicting. The primary-key
  blank-omission case (a key missing from `attrs` entirely) was already excluded from
  this check, but a key that's *present* with a `nil` value - the far more common shape
  for an ordinary nullable natural key - wasn't. Fixed by excluding any item where a
  `unique_by` column is nil (not just missing) from the duplicate-eligible set.
  **That first fix was itself incomplete - stated as "Postgres never treats a NULL as
  equal to anything", full stop, which is wrong for one real, available index type -
  found by a second external review, not this project's own testing at the time.**
  Postgres 15+ supports `CREATE UNIQUE INDEX ... NULLS NOT DISTINCT` (this app runs
  Postgres 18), which is exactly the opposite: it explicitly makes a `NULL` equal to
  another `NULL` for that index's conflict detection. Verified directly against a real
  such index: `nulls_not_distinct` comes back `true` on the `IndexDefinition` Rails
  resolves for it, and the identical two-nil same-batch upsert that inserts cleanly
  against an ordinary index instead raises `PG::CardinalityViolation` - the exact
  failure `assert_no_duplicate_unique_by_values!` exists to catch proactively, but the
  unconditional nil-exclusion from the first fix let it fall through anyway, straight
  into the same "empty line list, empty `#logs`" failure mode `isolate_failing_rows`'s
  row-by-row retry can't diagnose (see above) - confirmed directly: `"Row write failed
  for line(s) : ..."` (nothing between "line(s)" and the colon) with `logs` empty.
  Composite `NULLS NOT DISTINCT` behaves exactly like the ordinary case's own composite
  rule, just with the equality flipped for `NULL` specifically: verified directly that
  it only conflicts when *every* column matches, nil-equals-nil per column - two rows
  sharing a `NULL` in one column but differing in another still insert side by side
  with no conflict, even under `NULLS NOT DISTINCT`. Fixed by resolving and caching
  `index.nulls_not_distinct` alongside `@unique_by_columns` in `assert_unique_by_valid!`
  (`false`, unconditionally, for the primary-key shortcut path - a primary key can never
  be `NULL` in the first place, so this never has anything to matter for there), and
  having the guard only exclude a present-but-nil value when that flag is false.
- **`method_defined?` cannot be used to check whether a real column has a writer method -
  Rails generates those lazily.** Verified empirically: on a freshly-loaded model class
  that has never been instantiated anywhere in the process, `Post.method_defined?('title=')`
  returns `false`, and only becomes `true` after something calls `Post.new` for the first
  time (which is when Rails actually defines the attribute methods, not before). Using
  this alone for `:activerecord` mode's "is this attribute writable" check would have made
  correctness depend on whatever unrelated code happened to run earlier in the process -
  a real column could get rejected as invalid purely because nothing had touched the model
  yet. `assert_attributes_are_writable!` instead checks `attribute_names.include?` (schema-
  driven, not method-definition-driven, so it's reliable regardless of instantiation
  history) *or* `method_defined?` (which does reliably catch a hand-written `def slug=`,
  since that's a real method present at class-load time, not a lazily-generated one).
- **`:activerecord` mode's `on_failure :skip` only actually covers two specific exceptions -
  not "any way a row can fail."** `write_row_activerecord` rescues `ActiveRecord::RecordInvalid`
  (a validation failure) and `ActiveRecord::StatementInvalid` (a DB-level error from `save!`
  itself, e.g. a constraint `unique_by` doesn't cover); either is logged and the row is
  skipped. Verified empirically that nothing else is: a bad cast is caught and raised much
  earlier, in `build_attributes`/`resolve_cast`, before the row ever reaches `write_batch` -
  so it always aborts and rolls back the whole run, the same as `on_failure :rollback`,
  regardless of what's configured. Worse, a bug in the model's own code - a `before_save`/
  `before_create` callback that raises, or one that halts the chain with `throw :abort`
  (which surfaces as `ActiveRecord::RecordNotSaved`) - isn't rescued at all: it propagates
  uncaught, aborts and rolls back the whole run just like a bad cast, but *without* even a
  `#logs` entry first, since nothing catches it to call `log_error`. Confirmed against a real
  Postgres container: a 3-row file (good, bad, good) with `on_failure :skip` and a
  `before_create` that raises on the bad row left zero rows persisted and an empty `#logs`,
  not one entry for the bad row. **Left as-is on purpose, not an oversight**: `on_failure
  :skip` is a contract about a row's own *data* being unusable - a bad value, a failed
  validation - not about a bug in the model's own code (a `before_save` that raises,
  a broken `throw :abort`). That second case is a real bug in application code that
  belongs to whoever wrote the model, not to this importer - catching and logging it the
  same way as a bad row would make it look like routine, expected "skip" output instead of
  what it actually is, and make that bug harder to notice and debug, not easier. Letting it
  propagate uncaught, loudly, with a real backtrace, is the correct behavior here, not a
  gap to close.
- **The `activerecord-import` gem's `conflict_target` only accepts real column name(s),
  not an index name - unlike Rails' own `upsert_all`.** Verified empirically: passing an
  index name straight through (the way a subclass is allowed to declare `unique_by`
  everywhere else) raises `PG::UndefinedColumn: column "index_..._on_..." does not
  exist` - the gem interpolates whatever it's given directly as a column name, with no
  index-name resolution of its own. `Importer::Loaders::ActiverecordImport` sidesteps this
  the same way `Importer::Loaders::PlainRecord` already does for `find_or_initialize_by`:
  it passes `@unique_by_columns` (the real column list `assert_unique_by_valid!` already
  resolved and cached at config time, whether `unique_by` was declared as a column, a
  composite key, or an index name) as `conflict_target`, never `self.class.unique_by`
  directly - so an index-name declaration works here exactly like it does everywhere
  else, without the gem ever needing to understand index names at all.
- **The gem's `result.num_inserts` counts SQL statements issued, not rows written.**
  Verified empirically: importing 5 records with the gem's own `batch_size: 2` option
  produced `num_inserts == 3` (2 + 2 + 1 rows = 3 statements), not 5. Not something this
  class relies on for its own `@written_count`/`@skipped_count` bookkeeping (that's
  computed directly from `batch.size` and `result.failed_instances.size` instead), but
  worth knowing before reaching for `result.num_inserts` for anything - its name reads
  like a row count and isn't one. Also why this mode never passes the gem's own
  `batch_size:` option at all: batching is already `Importer::Base`'s job via its own
  `batch_size` macro, and one call to `.import` per already-sized batch keeps this mode's
  "one batch, one statement" cost model matching the raw_* modes'.
- **A bare backslash before a delimiter isn't an escaped delimiter - Ruby's CSV library
  only understands RFC 4180 double-quote wrapping.** Verified empirically:
  `aaa\,bbb` (no surrounding quotes) parses as two fields, `"aaa\\"` and `"bbb"`, not one
  field containing a literal comma - the backslash is kept as an ordinary character and
  the comma right after it still splits the row. `"aaa\,bbb"`, properly quoted, parses
  correctly as one field (the backslash is just kept literally inside it, unprocessed).
  This can silently shift every column after the offending one, without necessarily
  raising anything, if the shifted values happen to still look valid for whatever column
  they land in - worse than an unsupported delimiter or a non-double-quote quoting
  convention, both of which at least reliably fail loudly. A source file has to actually
  double-quote a field that contains its own delimiter - there's no way around this short
  of pre-processing the file before it ever reaches this class.
- **`verify_headers!`'s `CSV.open(&:shift)` doesn't read a whole file just to get its
  header row.** `&:shift` is shorthand for `CSV.open(path) { |csv| csv.shift }` -
  `CSV#shift` reads and returns just the next row, like `IO#gets` but per-row. Verified
  directly, not assumed: built a 2,000,000-row/41MB CSV, then checked the underlying
  file's read position (`file.pos`) after calling `.shift` once - it had advanced only
  32,768 bytes (Ruby's default IO read-buffer size), 0.075% of the file. Ruby's IO layer
  pulls one buffer's worth of bytes, CSV finds the first row inside it, and that's it -
  the remaining 41MB is never read.
- **A subclass of an already-configured importer lost every config macro - found by an
  external review, not this project's own testing at the time.** The config macros
  (`target_model`, `mode`, `required_headers`, etc.) store their value in a class-level
  instance variable (`@target_model` and so on) - and, verified directly, a
  class-level instance variable has no inheritance mechanism of its own in Ruby at all,
  unlike a method lookup: each `Class` object has entirely separate ivar storage, full
  stop. The class comment previously claimed the opposite ("a subclass still gets its
  own independent `@target_model` ... via normal class-level instance variable
  inheritance"), which conflated two different things - every concrete importer in this
  app *does* get independent storage, but only because each one subclasses
  `Importer::Base` directly and declares everything itself in its own class body, not
  because a subclass automatically inherits a value it never declared. Reproduced
  directly: subclassing `Importer::PostUpsertImporter` (rather than `Importer::Base`)
  without redeclaring anything came back `nil` for `target_model`, `mode`, every macro -
  exactly the pattern anyone reaching for "subclass an existing importer to reuse its
  config while tweaking one setting" would hit. Fixed with an `inherited(subclass)` hook
  that copies every one of the parent's instance variables to the subclass at the
  moment it's defined, rather than listing the macros by name (so it never needs
  updating when a new macro is added) - verified directly that this still gives each
  subclass its own independent copy: overriding one macro in the subclass afterward
  doesn't leak back and change the parent's own value.

## Excel (.xlsx) investigation

Core `.xlsx` reading (this section) and rich-text extraction (further below) are both
now implemented - `roo` is a real `Gemfile` dependency, and `caxlsx` is a `:test`-only
dependency for building `.xlsx` fixtures in specs (this app never writes `.xlsx` files
itself, only reads them). `openpyxl` (Python) and `exceljs` (Node) were only ever
installed system-wide, outside this project entirely, purely to answer "does any other
ecosystem already solve this" before landing on the Ruby-native approach for rich text -
neither is part of this project's stack.

### Gem choice

`roo` was chosen over `creek`. `creek` is purpose-built for streaming very large `.xlsx`
files with minimal memory footprint (closer to how this class's CSV side already
streams), but realistic import files here are thousands of rows, not millions - `roo`'s
maturity and its handling of real-world Excel messiness (multiple sheets, native cell
types, formulas) matters more than `creek`'s memory edge for files this size. Memory
handling still has to be verified once implementation starts, the same way `.shift` not
reading a whole CSV file was verified directly (file position after one read, not
inferred from timing) rather than assumed from either gem's documentation.

### File format detection

`.xlsx` is a ZIP archive under the hood (OOXML = XML files zipped together) - verified
directly (`xxd` on a freshly-created zip shows the first 4 bytes are `50 4b 03 04`,
i.e. `PK\x03\x04`, the standard ZIP signature). So an extension check alone isn't a
guarantee the file actually is one; the signature check catches a file that's merely
*named* `.xlsx`.

### Merged cells

A merge only stores its value in the top-left (anchor) cell - every other cell the merge
visually spans reads back as `nil` in the underlying data, even though Excel displays it
as if the value filled the whole merged block. Verified by building a real `.xlsx` with
a title row merged `A1:D1` and a header row with `B2:C2` merged ("Contact Info"), then
reading it back with `roo`:

```
Row 1 (title, merged A1:D1):  ["Company Report - Confidential", nil, nil, nil]
Row 2 (header, merged B2:C2): ["Name", "Contact Info", nil, "Quantity"]
```

So a header merged across two columns leaves the second column's actual header text
blank - which would otherwise surface as a confusing "missing required header" error
rather than a clear one about the actual cause (this is why a merged header cell raises
instead).

`roo`'s public API exposes zero merge information at all -
`Roo::Excelx.instance_methods.grep(/merge/i)` returns `[]`. But the raw sheet XML inside
the `.xlsx` zip does have it - a `<mergeCells>` element listing every merged range as
plain `A1:D1`-style refs:

```xml
<mergeCells count='2'>
  <mergeCell ref='A1:D1'></mergeCell>
  <mergeCell ref='B2:C2'></mergeCell>
</mergeCells>
```

**This must be read with a streaming (SAX) XML parser, never `Nokogiri::XML.parse` on
the whole entry** - verified empirically, not assumed, that this genuinely matters, not
just a micro-optimization. `<mergeCells>` sits *after* `<sheetData>` (all the row
content) in the OOXML schema's own element ordering, so reaching it means processing
through the whole sheet entry regardless of parsing approach - but *how* it's processed
is the difference between bounded and unbounded memory. Built a real 200,000-row
`.xlsx` (5MB compressed) whose single sheet decompresses to 52MB of XML, then measured
actual peak RSS for both approaches on that file:

```
Nokogiri::XML.parse (full DOM tree, whole entry read into a String first): 1.17GB peak
Nokogiri::XML::SAX::Parser (collects mergeCell elements as they stream past):  37.5MB peak
```

About 31x less - libxml2's per-node object overhead multiplies a 52MB document by
roughly 20x when building a full tree, whereas the SAX approach never builds one at all.
Same file, same information extracted, wildly different memory profile purely from the
choice of parsing API.

A merged cell in a decorative row above the header is not a problem - a row skipped
entirely via `header_row`/`data_start_row` is never read at all, merged or not.

### Cell formatting / rich text

The base class itself has no need to render a cell as HTML or anything else - it only
needs to *expose* whatever information about a cell is available, the same way
`raw_header_value`/`exclude_row?` already expose raw data for a subclass to do its own
thing with. What ended up mattering was how much work is required just to *gather* that
information in the first place, regardless of who consumes it.

**A single Excel cell isn't "one value with one style" - it can be a sequence of
independently-styled "runs".** Verified by building a real cell containing three runs
("te" plain, "sss" bold+italic, "ting" italic-only - matching an HTML-equivalent-ish
`te<i><b>sss</b>ting</i>`) and inspecting the raw XML it actually produces:

```xml
<is><r><rPr><b val="0"/><i val="0"/></rPr><t>te</t></r>
    <r><rPr><b val="1"/><i val="1"/></rPr><t>sss</t></r>
    <r><rPr><b val="0"/><i val="1"/></rPr><t>ting</t></r></is>
```

Three distinct runs, each with its own bold/italic combination, inside one `<c>`
element. A real gotcha hit while building this test worth remembering: `caxlsx` only
detects a cell's type (including `:richtext`) from the value passed at *cell
construction time* - assigning a `RichText` object via `cell.value = rt` *after* the
cell already exists silently does nothing (the cell's type was already locked in as
`:string` from its initial value), producing a cell whose value is literally the Ruby
object's `#inspect` string instead of real rich text. Only passing the `RichText` object
directly to `add_row`/`add_cell` at creation time actually works.

**`roo` has zero support for this - not partial, not messy, genuinely nothing.** Reading
the 3-run cell above back through `roo`: `sheet.cell(1,1)` returns `"tesssting"` (every
run flattened into plain concatenated text, all formatting discarded), and
`sheet.font(1,1)` returns a single `Roo::Font` claiming `bold=false, italic=false` -
actively wrong, not just absent, since the cell genuinely contains bold+italic text.
`roo` has no concept of a multi-run cell at all.

**Checked other ecosystems rather than assume Ruby's gap is universal - genuinely mixed
results, none a clean win on their own:**

- **Python's `openpyxl`** (`rich_text=True`) correctly extracted all three runs with
  their exact bold/italic combinations, verified directly. But `read_only=True` (its
  streaming mode) *silently* ignores `rich_text=True` and falls back to the same
  flattened plain text `roo` gives, with no warning - so genuine rich-text extraction
  forces the non-streaming path, and memory scales with the **whole workbook**, not the
  one cell asked about. Measured directly on a 200,000-row/3.2MB file with one rich-text
  cell buried in it:

  ```
  rich_text=True (full load, correct):        ~300MB peak
  read_only=True (streaming, no rich text):    ~37MB peak
  ```

  Roughly 8x, and that cost doesn't shrink no matter how deep in the file the cell of
  interest is.
- **Node's `exceljs`** has the right-shaped API (a `richText` array of `{text, font}`
  objects) but returned **wrong values** in testing - all three runs reported as
  `bold: true, italic: true`, when only one of the three actually has that combination.
  The source file was independently confirmed correct (its raw XML has three genuinely
  distinct `<b>`/`<i>` values per run, and `openpyxl` read the same file correctly) -
  this looks like a real bug in `exceljs`'s rich-text parsing, not a format quirk.
- LibreOffice headless (`soffice --convert-to html`) - a mature, full spreadsheet
  application, plausibly high-fidelity for this - wasn't available to test in this
  environment, so this remains unverified either way rather than assumed to work.

**A Ruby-native solution needed no new language or dependency: the same SAX-streaming
technique already proven for `mergeCells` detection extends directly to rich-text
runs.** Built a 150,000-row `.xlsx` (Ruby/`caxlsx`, 2.5MB) with one 3-run rich-text cell
buried at row 75,002, then wrote a `Nokogiri::XML::SAX` handler that tracks the current
cell reference, only starts collecting `<r>`/`<rPr>`/`<t>` data once it reaches the
target cell, and ignores everything else as it streams past. Correctly extracted all
three runs with their exact bold/italic values, and peaked at ~40MB - the same low,
bounded memory class as the `mergeCells` check, regardless of the file being 150,000
rows or 15.

Only bold/italic were actually verified through this handler - color
(`<color rgb="..."/>`), size (`<sz val="..."/>`), underline, and font name live in the
same `<rPr>` element and should extend the same way, but that's an extrapolation from
the same structure, not something separately tested yet.

First attempt at this handler gave wrong results, for a reason worth remembering:
`<b val="0"/>`/`<i val="0"/>` still means *false*, not "bold/italic present" - a handler
that treats "the `<b>` tag exists at all" as true, without checking its `val` attribute,
reports every run as bold.

### Memory is bounded, but time is not - and that changed the architecture

Measured directly on the same 150,000-row file: parsing the whole
`xl/worksheets/sheet1.xml` entry with a completely no-op SAX handler (doing nothing with
any element) still took ~1.9 seconds, while just decompressing the same entry into a
string with no XML parsing at all took 29ms. So the cost is Nokogiri/libxml2's
tokenization itself - walking every element and firing callbacks - not decompression,
and not anything a handler does with those callbacks. A lighter handler doesn't make
this faster; only reading less of the document does.

Adding early termination (raising once the target cell is found, instead of parsing to
the end of the document regardless) roughly halved a single lookup for a cell at the
file's midpoint (2059ms -> 1046ms) - meaningful, but still on the order of a second, and
that cost scales with how far into the sheet the target cell is, not with anything about
the cell itself.

This means lazy, per-cell, re-scan-from-scratch-every-time is only viable for a rare,
occasional lookup - calling it once for one specific row is fine. It is not viable for
the realistic case this was actually motivated by: a column (e.g. "Notes") that needs
rich-text fidelity on every row of a large import. Re-scanning the whole sheet entry
from scratch for every one of, say, 10,000 rows would mean roughly 10,000x a ~1-2 second
cost - hours, not a usable import.

**Resolved: one continuous streaming pass, paced by `Nokogiri::XML::SAX::PushParser`
instead of `parser.parse_io`, batched by accumulated byte size rather than row count.**
`parser.parse_io(io)` hands the whole IO to the parser and runs to completion in one
call - no way to pause, which is what forced "restart from the beginning" for every
fresh lookup above. `PushParser` inverts that: the caller reads the file in its own
chunks (64KB at a time in testing) and feeds each one to the parser directly, checking
after every chunk whether a batch is ready to hand off - so the underlying parser and IO
position simply continue from wherever they were, with no restart and nothing
already-consumed re-read.

Verified directly on the same 150,000-row file, processing the entire file in one pass
with 150 row-based batch boundaries:

```
Total time:    ~2 seconds  (the same as one full-file parse, paid once - not per batch)
Peak memory:   ~61MB       (bounded, same class as every other check here)
```

Bounded because each batch's collected data is discarded (not accumulated into one
growing structure) once handed off.

**A batch boundary must only be checked once a row is fully closed (`</row>`), never
mid-row.** First implementation of this checked "has the row number advanced past the
boundary" after every chunk - but a single very large row's XML can span multiple 64KB
chunks, and its row number is recorded as soon as `<row r="N">` *opens*, well before all
its cells have actually been read. That bug split one row's runs across what looked like
four separate batches in testing - caught by building a file with one deliberately huge
cell and watching the same row's data appear split across multiple reported batches,
which shouldn't happen.

**Row-count batching (e.g. "1000 rows") doesn't actually bound memory - it bounds how
many rows accumulate, not how large any single row or cell is.** Excel's own UI caps a
cell around 32,767 characters, but that's an application-level limit, not one the file
format itself enforces - a file built by something other than Excel's UI could have one
cell far larger than that. So batching is by accumulated byte size instead (a target
like 100MB), checked only at each row's close, with a floor of at least one row per
batch - unavoidable, since a row can't be split mid-cell without corrupting the
extracted result, so one pathological row just becomes its own (possibly oversized)
batch rather than being rejected or silently truncated.

Verified this adapts correctly on two opposite test files, using a much smaller target
(50KB, for practical test-file sizes) to force multiple flushes:

```
huge single cell (~167KB in one row, rest blank), target 50KB:
  1 batch, 166,950 bytes, covering the whole ~1002-row file
  (nothing else in the file contributed bytes until that one row was reached)

50,000 small, similarly-sized rows, target 50KB:
  8 batches, sizes: [101325, 98573, 55776, 206368, 55776, 206368, 55776, 8928] bytes
  rows per batch:   [6830, 6359, 3486, 12898, 3486, 12898, 3486, 558]
```

The row count per batch is whatever it takes to reach the byte target, not a fixed
number - many small rows group into large row-counts per batch; one huge cell becomes
its own batch immediately.

**The byte budget must be one combined counter shared across every column being
extracted in a pass, not one independent counter per column.** Tracking, say, 3 columns
needing rich-text fidelity with 3 separate 100MB counters would mean up to 300MB
worst-case, defeating the point of having a target at all. One shared counter,
incremented by every tracked column's data as it's collected, keeps the ceiling at
~100MB total regardless of how many columns are being tracked - practically, more
tracked columns just means each batch covers fewer rows before the shared budget fills,
not a higher ceiling.

**A subclass must declare which columns need rich-text fidelity upfront, not discover it
lazily inside `cast_<attribute>` - the batched design above requires this, it isn't just
a style preference.** The earlier idea was "call something from inside `cast_<attribute>`
when a cast override happens to want a cell's detail" - but by the time
`cast_<attribute>` runs for a given row, that row has already passed through the stream;
there's no going back to retroactively decide "actually, track this column too." So this
needs an upfront class-level macro (the same shape as `sheet_name`/`header_row`/
`csv_delimiter`) naming exactly which `required_headers`-mapped attributes need
rich-text extraction. That list is what tells the SAX extractor which cell references to
watch for at all, and is what makes "one shared byte counter across N columns"
well-defined from the start rather than growing as more columns get discovered
mid-import. `cast_<attribute>` then just looks up already-extracted data sitting in the
current batch's cache - a lookup, not a trigger.

**Confirmed: `batch_size` is already a universal concept, not something new needed for
this.** Every mode - including `:activerecord`, which saves one row at a time via
individual `save!` calls, not a bulk statement - already batches rows through the same
shared loop in `import!` (`batch << ...; write_batch(batch) if batch.size >=
self.class.batch_size`). What differs per mode is only what `write_batch` does with a
batch once called (one bulk SQL statement for the three bulk modes;
`write_batch_activerecord` just loops through and saves each row individually) - the
grouping into batches of `batch_size` (default `1_000`, confirmed directly from
`Concerns::Config`) is identical regardless of mode. So the rich-text extractor's
batches can share this exact same pacing across every mode, not just the bulk ones - no
new coordination concept needed, reusing what's already there.

**Despite the above, the byte-size-based batching was decided against for a first
version - deliberately, not because it doesn't work.** Everything measured above is
real and correct: byte-size batching is the only version with a genuinely bounded
memory ceiling regardless of what's inside any single cell. But it's also a second,
separate batching concept on top of the `batch_size` (row count) every other part of
this class already uses - more moving parts for a case (one pathologically huge cell)
that's rare in practice. The simpler call for a first version: reuse `batch_size` (row
count) for rich-text extraction too, the same as everything else, and accept that a
single very large cell can spike memory within its own batch - mitigated by a developer
manually configuring a smaller `batch_size` for an import known to have unusually large
cells, not by building automatic size-adaptive batching into the class. If this
actually becomes a real problem later, the byte-size approach above is already designed
and verified, not something that would need to be re-investigated from scratch.

### Core reading - implementation-time findings

Several things only surfaced while actually building the core reader (sheet/header
selection, merged-cell detection, native cell types), not during the earlier design pass:

- **`roo` already exposes exactly what merge detection needs, publicly.** The design
  above assumed re-deriving OOXML's sheet-name -> XML-file relationship would be
  necessary to find the right sheet's raw XML for the `<mergeCells>` SAX pass. Not so:
  verified directly that `Roo::Excelx#sheet_for(name).sheet_files` (and the top-level
  `#sheet_files`, once `default_sheet=` is set) is a public method returning the exact
  on-disk path to that sheet's already-extracted XML (`roo`'s `Spreadsheet.open` fully
  unzips the workbook to a tmpdir up front) - no private-API reach-in, no reimplementing
  relationship resolution `roo` already does correctly.
- **`Roo::Utils.extract_coordinate` is the current, non-deprecated way to turn `"B1"`
  into `[row, col]`** (`Roo::Utils.split_coordinate` raises a deprecation warning for the
  same thing) - verified directly: `extract_coordinate("B1")` => `[1, 2]`,
  `extract_coordinate("AA23")` => `[23, 27]`.
- **A literal `false` boolean cell would have been silently turned into `nil`, not
  written as `false`, without an explicit fix.** Verified directly: ActiveSupport's
  `Object#blank?` considers `false` blank (`false.blank?` is `true`, since the default
  `Object#blank?` falls back to `!self`). This never mattered for CSV - a CSV raw value
  is always a String, never a literal `false` - but an Excel boolean-formatted cell
  hands back a real `FalseClass` instance. Fixed with an explicit `raw_value != false`
  exemption in `default_cast`'s blank check; confirmed end-to-end (a `false`-valued cell
  round-trips as `false` in the database, not `NULL`).
  **The same root cause had a second, separate blast site this fix didn't cover - found
  later, by an external review, not this project's own testing.**
  `Importer::Base#import!`'s blank-row check
  (`row.values.all?(&:blank?)`) runs on the raw row *before* `default_cast` ever sees
  it, using the exact same `Object#blank?` - so a row where every other cell is
  genuinely empty except one `false`-valued boolean column was treated as fully blank
  and silently dropped by `drop_blank_rows` (the default), discarding a real row with
  no error and no log entry at all - worse than the original bug, since the row never
  even reached the point the first fix protected. Reproduced directly: a two-column row
  `[nil, false]` produced `processed: 0` in the summary log, meaning it was dropped
  before being counted as a row at all. Fixed by extracting the exemption into a shared
  `considered_blank?(value)` (`Importer::RowTransformer`) and using it in both
  places, rather than leaving two independent copies of the same one-line rule to drift
  out of sync again.
- **A native `Float` cell is safe to pass straight through to a Postgres `decimal`
  column - verified directly, not assumed, including a classic imprecise-binary-float
  case.** `100.15` has no exact binary floating-point representation, so if Rails'
  `ActiveRecord::Type::Decimal` ever cast a Float through its raw binary value
  (`BigDecimal(float_value)`), the classic failure mode would surface as something like
  `100.14999999999999...`. Verified directly against a real `decimal(20,10)` column:
  `100.15` (and `0.1`, `19.99`, `1234567.895`) all round-tripped exactly, matching
  `BigDecimal(float_value.to_s)` precisely - Rails converts via the Float's own decimal
  string representation, not its binary value, so no drift ever reaches the database.
- **`caxlsx` cannot produce a genuinely engine-computed formula cell.** Verified directly:
  even with `escape_formulas = false`, a cell written with a `=`-prefixed value comes
  back from `roo` as `nil`, because `caxlsx` is a pure writer with no formula engine - it
  never computes (or caches) a result the way real spreadsheet software does when saving
  a file. This means "formula cells always use the calculated value" has no dedicated
  automated test with a real engine-computed value; it's covered only by inspection and
  by the fact that it requires no special-case code at all - a normal cell-value read
  already returns whatever `roo` reports, and nothing in this class ever asks for a
  cell's formula text specifically.
- **A merged cell in a data row was decided during implementation, not left open**:
  raise, the same safe default the header row already uses. Not a considered design for
  the data-row case on its own merits - just consistent with treating a merge as an
  error everywhere it can hide data, and simplest to implement (the same
  `excel_merged_rows` Set check the header-row assertion already needed, reused for
  every data row during iteration, no new mechanism).
- **`roo` returns a whole-number cell as a `Float`, not an `Integer`, whenever the cell
  has a decimal (or percentage) number *format* applied, regardless of whether the value
  actually has a fractional part - found by an external review, not this project's own
  testing at the time.** Verified directly: a cell holding the value `42`, styled with a
  `"0.00"` number format, comes back from `roo` as `42.0` (`Float`). Excel's number
  format is a purely cosmetic display setting (how many decimal places to *show*) with
  no bearing on whether the underlying stored value is actually fractional - many real
  spreadsheets apply uniform decimal formatting across a whole sheet for visual
  consistency, even to columns that are conceptually whole numbers (a "Quantity"
  column, say). Since `NATIVE_TYPE_MATCHERS[:integer]` only matches an actual `Integer`,
  this `Float` falls through to the string-based path - `raw_value.to_s` produces
  `"42.0"`, and `Integer("42.0")` raises `ArgumentError` (confirmed directly), so the
  row fails with `invalid integer: "42.0"` even though converting `42.0` to an `Integer`
  loses nothing at all.
  **Deliberately left as-is, not fixed, after weighing the alternative.** An
  auto-accept rule (treat a `Float` as a native match for an `:integer` column whenever
  it has zero fractional part, e.g. `value == value.to_i`) was considered and rejected:
  it would add value-dependent branching to `default_cast` for a single specific case,
  in exchange for silently absorbing a case that's rare enough to not be worth that -
  and doing so would make the cast pipeline's behavior no longer uniform for every
  `Float`, undesirable for the same "no hidden behavior" reason `batch_size` was kept as
  the sole batching knob elsewhere in this file. The existing `cast_<attribute>`
  override mechanism already covers this without any change to `default_cast` at all -
  a subclass that hits this can pre-process the value and delegate the rest:
  ```ruby
  def cast_quantity(raw_value)
    raw_value = raw_value.to_i if raw_value.is_a?(Float) && raw_value == raw_value.to_i
    default_cast(:quantity, raw_value)
  end
  ```
  A genuinely fractional `Float` (e.g. `42.5`) mapped to an `:integer` column continues
  to raise unconditionally, both with and without this decision - that case is a real,
  lossy mismatch, not a formatting artifact, and nothing about this finding changes it.
- **The first implementation of merge detection had two bugs, both found by an external
  review, not this project's own testing at the time - see the "Merge detection" entry
  further below for the fix.**

### Rich text - implementation-time findings

Building the actual feature surfaced several things the design pass above didn't - and
changed two decisions from it (macro/accessor names, and dropping the byte-size
batching design in favor of reusing `batch_size` outright, already reflected above).

- **The design pass's "header text -> attribute" framing was wrong; corrected to plain
  header text, matching `raw_header_value`.** The original working name
  `rich_text_columns` implied declaring `required_headers`-mapped attribute names. That
  would have meant a rich-text column *had* to be mapped in `required_headers` just to
  be trackable - inconsistent with `raw_header_value`'s deliberate "any column, mapped
  or not" reach. Renamed to `rich_text_headers`, declared by exact header text; the
  accessor became `rich_text_header_value('Some Header')`, the direct parallel to
  `raw_header_value('Some Header')` rather than a new naming convention.
- **`cast_<attribute>`'s own `raw_value` stays exactly what it always was - plain,
  flattened text.** Rich-text data is a separate, additional lookup
  (`rich_text_header_value`), not a change to what a cast override's own argument
  contains - confirmed deliberately during design, not an implementation afterthought,
  since folding rich-text metadata into `raw_value` itself would have broken every
  existing `cast_<attribute>` override's assumption about that argument's shape.
- **`roo` extracts `sharedStrings.xml` to a flat, renamed sibling path, not the nested
  `xl/sharedStrings.xml` the original zip actually has - read directly from `roo`'s own
  source (`lib/roo/excelx.rb#process_zipfile_entries`), not guessed from the extracted
  directory's layout.** The design pass's assumption (rederive `xl/sharedStrings.xml` as
  a sibling of the sheet's own `xl/worksheets/sheetN.xml`) doesn't hold: verified
  directly that `roo` flattens every extracted member into one tmpdir with its own
  renamed files (`roo_sheet1`, `roo_workbook.xml`, `roo_styles.xml`, etc, all siblings,
  none nested under an `xl/` directory at all) - `excel_sheet_xml_path` itself already
  reflects this same flattening, so this isn't new information, just an assumption that
  needed re-checking for a second file. `roo`'s own `process_zipfile_entries` names the
  shared-string member `"#{tmpdir}/roo_sharedStrings.xml"` unconditionally, a plain
  sibling of `roo_sheetN` - confirmed by building a workbook with a hand-crafted
  shared-string table (below) and checking the resolved path exists and is readable at
  `File.join(File.dirname(excel_sheet_xml_path), 'roo_sharedStrings.xml')`.
- **`caxlsx` never produces `sharedStrings.xml` at all - every string it writes is
  inline (`t="inlineStr"`), confirmed by inspecting a workbook's raw zip members
  directly (no `xl/sharedStrings.xml` entry present, regardless of content).** This
  matters because a real Excel/Google Sheets/LibreOffice-authored workbook commonly
  uses shared strings instead (a dedup table referenced by numeric index, `t="s"`) - so
  a feature only ever tested against `caxlsx` fixtures would ship having verified just
  one of the two representations OOXML actually allows. Worked around by hand-assembling
  a fixture directly: serialize a throwaway `caxlsx` workbook for a valid zip skeleton,
  then overwrite `xl/worksheets/sheet1.xml` and add `xl/sharedStrings.xml` via `rubyzip`
  directly, with hand-written XML referencing shared-string indexes. Verified this
  approach end-to-end, including a shared string with its own multi-run rich-text data
  (`<si><r><rPr><b val="1"/></rPr><t>bold</t></r><r><t>plain</t></r></si>`) resolving
  correctly through the extractor.
- **Found in passing while building this feature, initially left as a documented TODO,
  then fixed after an external review correctly flagged it as a P1: `roo` mangled a
  shared-string cell with per-run formatting into an HTML-wrapped string for its
  *ordinary*, non-rich-text cell read - for every column, not just ones declared via
  `rich_text_headers`.** While building the hand-crafted shared-string fixture above,
  `wb.row(1)` (this class's own existing, pre-rich-text-feature cell read) returned
  `"<html><b>bold</b>plain</html>"` for that cell, not the plain `"boldplain"` text a
  developer would expect from a normal String column. Traced to `roo`'s own
  `Roo::Excelx::SharedStrings#use_html?`, which returns `true` (and switches the read to
  its HTML-wrapping `#to_html` path) for any shared string containing more than one run,
  regardless of anything this class configures. Initially left unfixed (documented as a
  README.md TODO instead) since it changes behavior for every existing Excel importer
  subclass, not just ones using the new feature - but an external review correctly
  pointed out this directly contradicts REQUIREMENTS.md's own documented contract that
  `raw_value`/`cast_<attribute>` always see plain, unaffected text, which isn't a
  tradeoff worth leaving in place just because the fix is broad. Fixed by passing
  `disable_html_wrapper: true` to `Roo::Spreadsheet.open` - `roo`'s own escape hatch
  (read directly from `use_html?`'s source: it short-circuits to `false` when this
  option is set) - verified directly against the same fixture that first surfaced the
  bug: the cell now reads back as `"boldplain"`, not the HTML-wrapped string. Has no
  effect on rich-text extraction itself, which never goes through `roo`'s cell-value API
  at all - `Importer::Parsers::ExcelX::RichText`'s own SAX handlers read the raw sheet/
  shared-strings XML directly, entirely independent of this option.
- **The design-phase `PushParser` batching plan (see "Memory is bounded, but time is
  not" above) held up unchanged against the real implementation, including its most
  fragile claim.** Re-verified directly, against the actual `RichTextExtractor`/
  `RunCapture` classes (not the throwaway design-phase script): feeding a sheet's XML in
  5-byte chunks (deliberately smaller than any single tag, to stress-test a chunk
  boundary landing mid-element) still produced exactly correct per-row run data, and
  pausing after one batch (`last_closed_row >= target`) then resuming for the next
  batch with the same parser/handler instance correctly picked up where it left off,
  with no re-read of already-consumed bytes and no data from the paused-past rows lost.
- **Only `bold`/`italic` were extracted at first - later extended to the rest of what
  `<rPr>` supports, plus per-cell background color, once asked for directly.** See the
  follow-up findings immediately below.

### Rich text - extending to size/color/font/underline/strikethrough/sub-superscript/background

Prompted directly (not something the original design pass scoped in): "why size and
color and font not check? we need all, even background color." Extending run-level
formatting was straightforward; background color turned out to need a structurally
different mechanism.

- **Confirmed directly against real generated XML (not assumed) that OOXML's `<rPr>`
  has no per-run background/highlight concept at all - unlike Word's `w:highlight`,
  spreadsheet rich text has nothing equivalent.** Read `caxlsx`'s own
  `RichTextRun::INLINE_STYLES` list (`font_name`, `charset`, `family`, `b`, `i`,
  `strike`, `outline`, `shadow`, `condense`, `extend`, `u`, `vertAlign`, `sz`, `color`,
  `scheme`) - no fill/background/highlight attribute anywhere in it. Then generated a
  cell with several distinctly-formatted runs and inspected the actual XML: every
  property serializes as its own direct child of `<rPr>` (`<b val="0"/>`,
  `<color rgb="FFFF0000"/>`, `<sz val="18"/>`, `<rFont val="Calibri"/>`,
  `<u val="double"/>`, `<strike val="1"/>`, `<vertAlign val="superscript"/>`) - simple,
  uniform shape, no nesting, confirming these all extend `RunCapture`'s existing
  `<b>`/`<i>` handling identically, just more tag names to switch on.
- **Background color lives entirely outside the run/cell-text structure - it's a
  property of the cell's *style*, resolved through two separate indirections, confirmed
  directly against real generated XML.** A cell styled with a background
  (`sheet.add_row([...], style: [style_id])` in `caxlsx`) serializes as `<c r="A3"
  s="3" ...>` - the `s` attribute is a positional index into `styles.xml`'s
  `<cellXfs>` section, *not* the similarly-shaped `<cellStyleXfs>` section (which lists
  *named* cell styles like "Normal" and is never what a cell's own `s` attribute
  indexes into - confirmed by inspecting a real `styles.xml`: both sections contain
  `<xf>` elements with the identical shape, so conflating them would silently resolve
  the wrong style for any workbook whose `cellStyleXfs`/`cellXfs` entry counts happen to
  differ). That `<xf>`'s own `fillId` attribute is then a *second* positional index,
  into `<fills>`, where the actual color lives at `<fill><patternFill
  patternType="solid"><fgColor rgb="..."/></patternFill></fill>`. `roo`'s own `Styles`
  class (`lib/roo/excelx/styles.rb`) confirms this isn't something `roo` already
  exposes - it resolves a style index to a *font* only (`extract_fonts`, bold/italic/
  underline), never touching `fills` at all.
- **A fill's `patternType` matters, not just its `fgColor` - `"solid"` is the only
  pattern type where `fgColor` is actually the visible background.** A cell with no
  explicit style at all still has `fillId="0"`, whose `patternFill patternType="none"`
  has no `fgColor` element at all - and Excel's own "gray125" pattern (used internally
  for certain built-in styles) has a real `fgColor` that isn't a solid background
  either. `StylesHandler#background_color_for` returns `nil` for anything other than
  `patternType="solid"`, rather than returning whatever `fgColor` a non-solid pattern
  happens to carry.
- **A run's `color` and a fill's `fgColor` share the exact same `<color .../>`-shaped
  attributes (`rgb`/`theme`/`indexed`/`tint`) - one shared extraction helper, not two.**
  Neither value is resolved to a final RGB when it's `theme`- or `indexed`-based (both
  reference a lookup table - the workbook's theme XML, or the legacy fixed 64-color
  palette - that isn't parsed here) - the raw attribute(s) are returned as-is instead of
  silently dropping a color that isn't `rgb`-based, or claiming a resolved value that
  wasn't actually computed.
- **A blank cell can still have a background - `runs` and `background_color` had to
  become independent, not one gating the other, once background needed representing at
  all.** This directly motivated `rich_text_header_value`'s return-shape change (from a
  bare Array of runs to `{ runs:, background_color: }`) - confirmed with the requester
  before implementing, since it changes an already-built-and-spec'd return type rather
  than only adding new data alongside it. Verified directly: a cell with a background
  fill and no text content at all resolves to `{ runs: nil, background_color: {...} }`,
  not one nil-ing out the other.
- **`u`'s (underline) absent-`val` default was the one place this extension needed the
  same "check the actual attribute, don't assume presence means one specific value"
  discipline as `<b val="0"/>` - but in the opposite direction.** A bare `<b/>` with no
  `val` means bold=true (any non-`"0"` `val`, including a missing one, means true); a
  bare `<u/>` with no `val` also means present/true, but *which* underline style is
  ambiguous without checking the spec - OOXML's own default for an absent `val` is
  `"single"`, not an arbitrary/undefined choice, so `RunCapture` defaults to `:single`
  rather than leaving `underline` `nil` (which would incorrectly mean "no underline at
  all") whenever `val` is missing.
- **`<b val="0"/>` still means false was already a known gotcha here - but the fix only
  ever checked for `"0"`, not the other form XML Schema's own boolean type equally
  allows - found by an external review, not this project's own testing.** XML Schema's
  boolean lexical space is `{"true", "false", "1", "0"}` - `val="false"` is exactly as
  valid as `val="0"`, but `attrs['val'] != '0'` treated a spec-valid `val="false"` as
  true (`"false" != "0"`), for `<b>`, `<i>`, and `<strike>` alike. Verified directly,
  reproduced in isolation before touching the real class: `val="false"` returned
  `bold: true`. Never caught by this project's own specs because `caxlsx` (the only
  fixture generator available) always normalizes a boolean run property to `"1"`/`"0"`
  via its own `RichTextRun#xml_value` (`value == false ? 0 : ...`) and never emits the
  `"true"`/`"false"` form at all - the same "only ever tested against caxlsx, not a
  real-world-representative writer" gap already noted for the inline-vs-shared-string
  distinction. Fixed by checking against both false forms (`%w[0 false]`) rather than
  just one; the new regression spec has to hand-write the sheet XML directly (via
  `rubyzip`, the same technique already used for the shared-string case) since `caxlsx`
  itself can't produce a `val="false"` to test against.
- **A phonetic-hint run (`<rPh>`) was silently treated as an ordinary text run,
  polluting `runs` with a bogus extra entry that isn't part of the cell's real text at
  all - found by an external review, not this project's own testing.** `<si>`/`<is>`
  share one OOXML type (`CT_Rst`), which allows one or more
  `<rPh sb="0" eb="2"><t>...</t></rPh>` elements alongside the real `<r>` runs - a
  pronunciation hint (Japanese furigana, most commonly) for a *range of the base text*,
  not itself part of that text. `<rPh>`'s own `<t>` child has the identical element name
  as a real run's text, and `RunCapture` had no notion of "currently inside `<rPh>`, not
  `<r>`" at all - so a cell with base text "漢字" and phonetic hint "かんじ" came back as
  **two** ordinary runs, `[{text: "漢字", ...}, {text: "かんじ", ...}]`, not one.
  Reproduced directly, against the real classes (not a standalone script), before fixing
  anything: a hand-built `<si>`/`<is>` each containing `<rPh>` both showed the bug
  identically, confirming it affects the inline-string and shared-string paths equally
  (both ultimately funnel every `<r>`/`<rPh>`/`<t>` element through the same shared
  `RunCapture`).
  - Fixed with an `@in_phonetic_run` flag on `RunCapture`, set true on `<rPh>`'s
    `start_element` and false on its `end_element`, checked before either starting or
    committing a `<t>`'s text buffer - `</t>` always closes before `</rPh>` does (`<t>`
    is `<rPh>`'s only child, per the schema), so the flag is still accurately true right
    up through `<t>`'s own `end_element`.
  - **A second, easy-to-miss half of the same fix**: `RichTextExtractor` (the inline-
    `<is>` path) only ever forwards elements in its own `RUN_ELEMENTS` allowlist to
    `RunCapture` at all - unlike `SharedStringsHandler` (the `<si>` path), which
    forwards everything unconditionally. `rPh` wasn't in that allowlist, so even with
    `RunCapture`'s flag added, an inline cell's `<rPh>` open/close would never actually
    reach `RunCapture` to set it - only `<rPh>`'s *nested* `<t>` was in the allowlist and
    would still reach it. Caught by testing the inline path specifically, not assuming
    the shared-string fix covered both automatically; `rPh` added to
    `RichTextExtractor::RUN_ELEMENTS` alongside the `RunCapture` change.
  - `caxlsx` has no API for phonetic runs at all, so both the inline and shared-string
    regression fixtures for this are hand-built directly with `rubyzip` - the same
    technique already established for every other OOXML shape `caxlsx` can't produce.
- **A formula cell's own cell type (`t="str"`) wasn't handled at all - its cached string
  result silently came back as `runs: nil`, the same as a genuinely empty cell, rather
  than the single unstyled run the documented contract promises for any plain string -
  found by an external review, not this project's own testing.** `RichTextExtractor`
  only ever read `<v>` as an index into the shared-string table when `t="s"` - for every
  other cell type (including `t="str"`, a formula whose *computed result happens to be
  a string*), `<v>`'s content was never read at all, since a formula cell's result is
  never wrapped in `<is>`/`<r>` (there's no per-character formatting to compute for a
  dynamically-computed value - it's always one flat string). Verified directly, against
  a hand-built `t="str"` fixture (`<c t="str"><f>...</f><v>Header!</v></c>` - `caxlsx`
  can't produce a real engine-computed formula result at all, see this file's "Core
  reading" findings above), before fixing anything: `rich_text_header_value` returned
  `{ runs: nil, background_color: nil }` for a cell that plainly contained `"Header!"`.
  Fixed by routing a `t="str"` cell's `<v>` through the same `RunCapture` instance as if
  it were a bare, unwrapped `<t>` - `RunCapture#start_element('t', {})` at `<v>`'s own
  open, then its normal `characters`/`end_element('t')` handling - reusing the exact
  path that already produces a single unstyled run for a plain, non-rich string,
  rather than duplicating that "build one run" logic a third time.
- **`styles.xml` was wrongly assumed mandatory - `excel_cell_styles` would raise (file
  not found) once `rich_text_headers` was declared against a valid workbook that simply
  doesn't have one - found by an external review, not this project's own testing.**
  Unlike `excel_shared_strings` (which already checked `File.exist?` first, since a
  workbook using only inline strings has no shared-string table either), the styles
  reader assumed the part always exists. Verified directly: removed `xl/styles.xml`
  from an otherwise normal workbook (leaving the stale `[Content_Types].xml`/
  `workbook.xml.rels` references in place - `roo` doesn't validate those against actual
  zip members) - `Roo::Spreadsheet.open` still opened it fine, and `roo`'s own
  `process_zipfile_entries` correctly never created `roo_styles.xml` on disk in that
  case (it only ever creates a tmpdir file for a zip member that actually exists) - so
  this class's `Nokogiri::XML::SAX::Parser#parse_file` call was reaching for a path
  nothing had ever created. Fixed with the same `File.exist?` guard
  `excel_shared_strings` already has: skip the parse entirely when the file's absent,
  and a `StylesHandler` that's never fed any SAX events already resolves every style
  index to no background (`@cell_xf_fill_ids`/`@fills` both start empty) - the correct
  answer for a workbook with no fills defined anywhere, so no other change was needed.
  **One caveat found while building the regression fixture**: a workbook with any
  specially-*formatted* cell (a `Date` column, in particular, which needs its own
  `numFmt` style to be recognized as a date rather than a raw serial number) makes
  `roo` *itself* raise `Roo::FileNotFound` once `styles.xml` is removed, entirely
  independent of anything this class does - `roo`'s own `style_format`/date detection
  needs that part to exist for such a cell. So the fixed code path here is only
  reachable in practice for a workbook with no specially-formatted cells at all
  (every column reads at its default style) - the regression spec uses a deliberately
  minimal two-column, plain-string-only fixture for exactly this reason, not the
  richer shared fixture layout every other Excel spec in this file reuses.
- **Closing the rich-text reader only ever ran after `each_row`'s row loop finished
  normally, not on any failure path out of it - found by an external review, not this
  project's own testing.** A bad cast, a merged data row, or a DB-level failure from
  `write_batch` (called from inside `import!`'s own row loop, back in `base.rb`) all
  raise from *inside* that loop, and the plain trailing method call sitting after it
  simply never runs once any of them does - leaking the rich-text file handle
  (`Importer::Parsers::ExcelX::RichText`'s own `@file`) until Ruby's GC
  eventually finalizes the object, on no particular schedule. Verified directly, before
  fixing anything: forced a `cast_<attribute>` to raise mid-import (with
  `rich_text_headers` declared, so the file was actually opened), caught the raised
  `ImportError`, and confirmed the handle's own `closed?` was still `false` afterward.
  Fixed with a method-level `ensure` on `each_row` instead of a plain trailing
  call, guaranteeing the close runs on every exit path, not just the
  successful one - re-verified against the same reproduction that the handle is
  `closed?` `true` once `import!` raises now.

### Rich text - a second external review batch, six confirmed bugs plus three small additions

Received as one batch, from two independent reviewers with some overlap. Each item
below was verified directly against the real classes before being fixed, the same
discipline as every other finding in this file - none were taken on faith.

- **Column index off-by-N whenever a sheet's used range doesn't start at column A -
  the most severe of this batch, since it silently returns a *different, real*
  column's data rather than nothing at all.** `rich_text_target_columns` computed a
  header's absolute column number as `index + 1` against `excel_workbook.row(header_row)`
  - but verified directly that `roo`'s own `row()` starts at the sheet's *first used
  column*, not always column A: a sheet whose used range starts at column B returns
  `["Name", "Notes"]` from `row(1)`, with `excel_workbook.first_column` reporting `2`,
  not `1`. So `index + 1` mapped "Name" (actually column B) to column 1 (A), and
  "Notes" (actually column C) to column 2 (B) - which is "Name"'s own real column.
  Reproduced directly before fixing: `rich_text_header_value('Notes')` returned the
  "Name" column's runs. `Importer::Parsers::ExcelX#excel_row_hash` isn't
  affected the same way - it only ever pairs a header at array position `i` with a
  data row's value at that same position `i`, never computing an absolute column
  number, so the same first-column offset applies to both header and data reads and
  cancels out. `rich_text_target_columns` is different: it has to produce an absolute
  column number, because `RichTextExtractor` matches it against a cell's own
  `r="B1"`-style reference (`Roo::Utils.extract_coordinate`), which is always absolute
  regardless of where the sheet's used range starts. Fixed with
  `index + excel_workbook.first_column`.
- **`val="none"` (for `<u>`) and `val="baseline"` (for `<vertAlign>`) both came back as
  truthy `:none`/`:baseline` symbols, contradicting the documented `nil`-means-none
  contract - the same class of mistake as the `<b val="0"/>`-still-means-false bug
  already fixed above, just spelled as a word instead of a boolean lexical form.**
  Verified directly before fixing: a run with `<u val="none"/><vertAlign
  val="baseline"/>` came back `underline: :none, vertical_align: :baseline` - both
  truthy, both meaning "nothing special here" per OOXML. Fixed by treating `"none"`/
  `"baseline"` as the signal to leave the property at its `nil` default, rather than
  assigning a symbol for them.
- **A numeric/boolean/date/error cell in a `rich_text_headers` column returned
  `runs: nil`, indistinguishable from a genuinely blank cell - `<c r="B2"><v>42</v>
  </c>` lost its `"42"` undetectably.** Only `t="s"` (shared-string index) and, since
  the earlier fix in this file, `t="str"` (formula-cached-string) ever read `<v>`'s
  content at all - every other type that legitimately stores its value directly in
  `<v>` (no `t` attribute at all, meaning a plain number; `t="b"`; `t="e"`; the rare
  `t="d"`) was left completely unhandled, silently indistinguishable from "nothing
  here." Verified directly before fixing: a `<c r="B2"><v>42</v></c>` cell (no `t`
  attribute) returned `runs: nil`. Fixed by generalizing the existing `t="str"`
  mechanism (treat `<v>` as literal text via `RunCapture`, the same path a plain
  string already takes) to *any* cell type reaching that branch, not just `"str"` -
  none of these types can ever be genuine rich text (a number/boolean/error/date has
  no per-character formatting to compute), so a single unstyled run is the correct,
  complete answer for all of them.
- **A `<row>`'s own `r` attribute is optional per `CT_Row` - an absent one silently
  collapsed every such row to row 0.** `attrs['r'].to_i` assumed `r` always present;
  `nil.to_i` is `0` in Ruby, not an error, so a row with no `r` attribute was recorded
  as row 0 - `@cells[0]` overwritten by each subsequent such row, `last_closed_row`
  stuck at 0 forever (since every real target row number is `>= 1`), and every
  rich-text lookup silently returning `nil` while the import otherwise completed
  without any error at all. Per the OOXML spec, an absent `r` means "one more than the
  previous row's index" - fixed by tracking a running `@next_implicit_row` counter,
  advanced from whichever index a row actually ends up with (explicit or implicit) so
  the fallback stays correct even after a row that *did* have an explicit,
  possibly-non-sequential `r`. Verified directly: two rows with no `r` attribute at
  all now correctly resolve to rows 1 and 2, in document order.
- **A namespace-*prefixed* sheet (`<x:row>` under an `xmlns:x` declaration, instead of
  the default-namespace `<row>` every real workbook this project has seen actually
  uses) bypassed every `case name when 'row'`-style dispatch in this codebase
  entirely, silently - `MergedCellsHandler` (merge detection) included, not just the
  rich-text handlers.** Traced directly to Nokogiri's own source: its default
  `start_element_namespace` (called for every element whenever *any* namespace is in
  effect, which every real `.xlsx` sheet/sharedStrings/styles XML always has via its
  own `xmlns="...spreadsheetml..."` declaration) rejoins an element's prefix back onto
  its local name before delegating to `start_element` -
  `name = [prefix, name].compact.join(":")`. A default namespace (no prefix, what
  `caxlsx` and every real `.xlsx` this project has seen actually declares) is
  unaffected (`[nil, "row"].compact.join` is just `"row"`), but a prefixed one isn't -
  verified directly, before writing any fix, that a handler defining only
  `start_element`/`end_element` (exactly what every SAX handler in this codebase does)
  receives the qualified `"x:row"` for such a document, matching none of the plain
  names any handler checks for. Fixed with one shared mixin
  (`Importer::Parsers::ExcelX::XmlNamespaceAgnostic`, `parsers/excel_x/xml_namespace_agnostic.rb`),
  included by all four affected handlers (`MergedCellsHandler`, `RichTextExtractor`,
  `SharedStringsHandler`, `StylesHandler`) rather than patched separately in each -
  overrides `start_element_namespace`/`end_element_namespace` to forward the already-
  local `name` directly, without Nokogiri's own prefix-rejoining. Re-verified against a
  hand-built `<x:row>`/`<x:c>`/`<x:t>` fixture that rich-text extraction now works
  correctly through it.
- **`rich_text_header_value`'s own "is this header actually declared" guard compared
  its normalized lookup argument against the *raw*, un-normalized
  `self.class.rich_text_headers` array - so `rich_text_headers [:Notes]` (a symbol) or
  `rich_text_headers [' Notes ']` (untrimmed) tracked the column correctly during
  extraction, then raised "is not declared" calling `rich_text_header_value('Notes')`
  with the exact, correctly-spelled header text.** `rich_text_target_columns` already
  normalized each declared entry (`.to_s.strip`) before matching it against the
  file's actual header row, but the separate declared-header check in
  `rich_text_header_value` never applied that same normalization to the array it
  compared against. Reproduced directly before fixing: `rich_text_headers [:Notes]`,
  then a full import calling `rich_text_header_value('Notes')` from `cast_body`,
  raised despite the column extracting correctly. Fixed with one shared
  `normalized_rich_text_headers` helper, memoized once, used by both call sites - not
  two separate normalization steps that could drift out of sync again.
- **A valid `auto="1"` color attribute (`{"auto" => "1"}`) was discarded entirely,
  resolving to `nil` - identical to "no color specified at all" rather than
  "explicitly automatic."** `extract_color_attrs` only ever checked for `rgb`/
  `theme`/`indexed`/`tint`; `auto` (OOXML's fourth, mutually-exclusive way for a
  `<color>` element to identify itself - "let the renderer choose," typically default
  black text or no fill) was missing entirely. Fixed by adding `color[:auto] = true if
  attrs['auto'] == '1'`.
- **`outline`/`shadow` were left out of `RunCapture` under the same "compatibility
  metadata, not visible formatting" reasoning as `family`/`charset`/`scheme` - which
  is wrong for these two specifically.** An earlier version of `RunCapture`'s own
  class comment mischaracterized them; both are genuinely visible, rendered text
  effects (a hollow/embossed outline font style, a drop shadow on the text) in
  Excel/legacy Office - `family` (font pitch/serif classification for fallback
  substitution), `charset` (legacy encoding), and `scheme` (which named theme font a
  run uses) remain correctly excluded, since none of those three change how the text
  actually looks beyond what `rFont`/`sz` already communicate. Added `outline`/
  `shadow` as boolean run properties, using the same `FALSE_VALUES` check already
  established for `b`/`i`/`strike` (same boolean lexical space, same `<b val="0"/>`-
  class gotcha).
- **Gradient fills (`<gradientFill>`, a sibling of `<patternFill>` inside `<fill>`)
  were never considered at all, and remain unsupported - a real, if less common,
  OOXML fill representation this feature doesn't cover, worth being explicit about
  rather than letting `background_color: nil` read as "definitely no fill" for every
  possible case.** `StylesHandler` only ever looks for `<patternFill
  patternType="solid">`; a cell filled via a two-or-more-stop gradient instead
  resolves to `nil`, the same as a genuinely unfilled cell - not fixed, given the
  added complexity (multiple color stops, an angle or path, a fill-type distinction)
  for what's a comparatively rare real-world case, but now explicitly documented
  rather than silently absent from the record (see README.md's TODO section).
- **RSpec coverage feedback**: line coverage alone (99%+ before this batch) doesn't
  prove every *branch* of a value is exercised - a `theme`/`indexed`/`tint`/`auto`
  color, in particular, could execute its line without any assertion ever checking
  the resulting value's shape. Added dedicated specs for a theme+tint color, an
  indexed color, and the new `auto`/`outline`/`shadow` properties, each asserting the
  actual returned Hash rather than just not-raising. The styleless-workbook regression
  spec also only ever removed `xl/styles.xml`'s own zip entry, leaving
  `[Content_Types].xml`'s `Override` and `xl/_rels/workbook.xml.rels`'s
  `Relationship` pointing at it dangling - `roo` doesn't validate either against
  actual zip members, so the test still passed, but it wasn't exercising a workbook
  that's genuinely, internally valid without a styles part; rebuilt to strip both
  references too.

**Initially flagged back to the user rather than silently built or silently skipped,
then built once they confirmed they wanted it**: a plain (non-rich-text) cell's
formatting applied entirely through its own *cell style* (`cellXfs[s].fontId` →
`<fonts>`) rather than a run - e.g. a whole cell made bold via "Format Cells" rather
than a rich-text run - previously read back with every property at its default
(`bold: false`, etc.), even though the cell visibly renders bold.

### Rich text - cell-level style fallback for a plain cell

- **Scope deliberately narrowed to "a cell with no rich-text run of its own", not full
  per-property inheritance for every run.** The design question raised when this was
  first flagged: OOXML's own rule is that a run's `rPr` inherits from the cell's font
  *per property*, not all-or-nothing - a run that specifies its own bold but not its
  own color would, in principle, still inherit the cell's color. Implementing that
  fully would require tracking, per property, whether a run *explicitly* set it versus
  left it at `BLANK_RUN`'s uninformative default - which nothing in `RunCapture`
  currently does, and which every real (`caxlsx`-or-Excel-produced) file this project
  has actually seen doesn't seem to need: a genuine rich-text run's own `<rPr>` is
  self-contained in practice, writing out every property it cares about explicitly
  rather than leaving some to inherit. So the fallback applies only when a cell has
  **no** run-level formatting at all (`RunCapture#had_run?` false - a bare `<t>`,
  wrapped in neither `<is>`'s nor `<si>`'s `<r>` at all) - a cell that *does* have its
  own rich-text run(s) is completely unaffected, its own runs used exactly as written.
  Per `CT_Rst`'s own schema, at most one bare `<t>` can appear per `<si>`/`<is>`, so
  `runs` is guaranteed to be either `nil` or exactly one entry whenever `had_run?` is
  false - no ambiguity about how many entries the fallback needs to replace.
- **`had_run?` had to be threaded through the shared-string path too, not just the
  inline one** - a shared string entry can equally be either a bare `<t>` (plain) or
  wrapped in real `<r>` elements (rich), and that distinction is lost the moment
  `RunCapture#finish!`'s result alone is looked at (a single-run result looks the same
  either way). `SharedStringsHandler` now tracks a parallel `@had_run` array alongside
  `@entries`, one entry per shared string, exposed via `#had_run?(index)`.
  `excel_shared_strings` itself was changed to return the whole `SharedStringsHandler`
  instance rather than just its `#entries` array (the same shape `excel_cell_styles`
  already returns for `StylesHandler`) so `RichTextExtractor` can reach both.
- **A `<font>` definition (in `styles.xml`'s `<fonts>`) uses `<name>` for the font
  name, not `<rFont>` (the one difference from a run's own `<rPr>` - confirmed
  directly against real generated XML: `<font><name val="Arial"/><sz val="11"/>
  <family val="1"/></font>`) - everything else (`<b>`, `<i>`, `<strike>`, `<u>`,
  `<sz>`, `<color>`, `<vertAlign>`, `<outline>`, `<shadow>`) is identical in shape to a
  run's own properties.** Refactored the property-dispatch logic itself (previously
  `RunCapture`'s own private `apply_run_property`) into a shared module-level
  `Importer::Parsers::ExcelX::RichText.apply_formatting_property`, accepting either
  element name as a synonym for the same `:font` key - one dispatcher for both a run's
  `<rPr>` and a standalone `<font>` definition, not two copies of the same
  bold/italic/underline/etc gotchas to keep in sync.
- **A cell's `fontId` (like `fillId`) is a positional index into `<cellXfs>`'s own
  `<xf>` elements, resolved the exact same way background color already was** -
  `StylesHandler` now tracks `@cell_xf_font_ids` alongside `@cell_xf_fill_ids`, and
  `#font_for(style_index)` mirrors `#background_color_for` exactly, including the
  "absent `fontId` defaults to 0" convention (`nil.to_i` is `0` in Ruby, matching
  OOXML's own `default="0"` for this attribute).
- **Verified directly, before considering this done, that a genuinely rich-text cell
  is unaffected even when its own cell style is bold/colored**: built a cell with an
  explicit italic-only run *and* a bold/red cell style applied - the returned run
  showed only `italic: true`, with no bold/red leakage from the cell style at all,
  confirming the `had_run?` gate actually excludes this case rather than merging.
  Also verified the plain-cell case directly against a real generated fixture (a cell
  styled bold/14pt/red/Calibri via "Format Cells", no rich-text run): the returned
  single run correctly reported `bold: true, size: 14.0, color: {rgb: "FFFF0000"},
  font: "Calibri"`.
- **Every existing "plain cell" regression spec had to be updated once this landed -
  not a sign of a bug, the direct and expected consequence of the fix.** Every fixture
  in this file's specs is either `caxlsx`-generated or built from a `caxlsx`-generated
  skeleton (only its sheet/sharedStrings XML patched directly) - and `caxlsx` always
  assigns a real default font (`Arial`, 11pt) at `fontId` 0, the same as any real
  workbook would. So a "plain, unstyled" cell in this test suite was *never* actually
  going to report `font: nil, size: nil` again once the fallback existed - every one
  of those assertions was quietly relying on the *absence* of a feature, not a
  meaningfully different state. Added a dedicated `expected_plain_run` spec helper
  (wrapping `expected_run` with `font: 'Arial', size: 11.0`) rather than baking the
  fallback into `expected_run` itself, since the fallback genuinely doesn't apply to
  a cell with its own explicit rich-text run - the two helpers stay meaningfully
  different, not just cosmetically.

### Rich text - a third external review round, two more confirmed bugs plus two small additions

- **`<c>`'s own `r` attribute is optional per `CT_Cell`, exactly like `<row>`'s own `r`
  - the identical bug, in the sibling place, found by the same kind of review as the
  row-level one.** `extract_column(nil)` returns `nil` (its own `return nil unless ref`
  guard), so `column && @target_columns.include?(column)` was always false for such a
  cell - it was silently never treated as a target-column cell at all, no matter which
  column it was actually in, while the sheet still imported without any error at all.
  Verified directly before fixing: a two-column sheet with the target column's own
  `<c>` omitting `r` entirely returned `nil` for `rich_text_header_value`, despite the
  workbook importing successfully otherwise (`roo`'s own header/data reads already
  handle a missing `r` correctly, confirming the workbook itself is valid). Fixed with
  the exact same pattern as the row-level fix: a running `@next_implicit_column`
  counter, reset to `1` at each `<row>`'s own start (column position restarts every
  row) and advanced from whichever column a cell actually ends up at, explicit or
  implicit.
- **`auto="true"` was still missed - only `auto="1"` was recognized, even though
  `auto` is itself an XML Schema boolean whose valid true forms are both.** The exact
  same class of gotcha `FALSE_VALUES` already exists to handle for `<b>`/`<i>`/etc,
  just for this one attribute specifically (`AUTO_COLOR_VALUES = %w[1 true]`) rather
  than a whole boolean sub-element - `attrs['auto'] == '1'` alone left `{auto: true}`
  for one spelling and `nil` (indistinguishable from "no color specified at all") for
  the other. Verified directly before fixing: a hand-built run with `<color
  auto="true"/>` resolved to `color: nil`.
- **`condense`/`extend` (squeezing/stretching the rendered text horizontally) are
  genuinely visible effects per Microsoft's own documentation, even though modern
  applications aren't required to honor them - an earlier version of `RunCapture`'s
  own comment grouped them in with `family`/`charset`/`scheme` (which really are
  non-visual and correctly stay excluded) rather than with `outline`/`shadow` (which
  had already been corrected once for the same mistake).** Added as two more boolean
  run properties, same `FALSE_VALUES` pattern as `outline`/`shadow`.
- **Coverage**: `advance_rich_text_through!`'s EOF-before-target-row branch (calls the
  parser's own `#finish` and stops, rather than raising, if a requested row number is
  never actually reached) had no direct test - it's a safety net for a case that
  "shouldn't happen" in a real import (row numbers `each_excel_row_number_and_values` asks for are
  already bounded by `excel_workbook.last_row`), which is exactly why it's worth
  exercising directly rather than trusting by inspection alone. Added a spec calling
  it with a row number far beyond the fixture's actual content, confirming it neither
  raises nor hangs.

### Rich text - a fourth external review round: family/charset/scheme, and full fill support

- **The `condense`/`extend` correction (added the previous round) never made it into
  every place that described them - `RunCapture`'s own class comment, and a duplicate
  mention two paragraphs later, still listed both as unextracted alongside `family`/
  `charset`/`scheme`.** Same underlying fact, stated in three different comments, only
  two of which got updated last time. Fixed by rewriting the comment to describe what
  actually happens now rather than repeating the same "except X, Y, Z" list in
  multiple places that can individually go stale.
- **`family`/`charset`/`scheme` were still being characterized as safe to skip
  entirely, purely non-visual metadata - not accurate, per an external review's
  pushback, not this project's own testing.** Re-examined each one on its own merits
  rather than treating all three the same way:
  - `scheme` (`none`/`major`/`minor`) genuinely determines *which font actually
    renders* whenever a run has no explicit `rFont` of its own and instead uses a
    workbook theme font - this is exactly the same category of "what's actually
    displayed" as `rFont`/`font` itself, not metadata about it.
  - `charset` and `family` (font pitch/serif classification: Roman/Swiss/Modern/
    Script/Decorative) are, per Microsoft's own documentation, both font-matching/
    substitution hints - which physical font to pick as a replacement when the named
    one isn't available - not directives that change how the run's *own* text is
    interpreted or displayed. A run's text is always Unicode regardless of `charset` -
    an earlier version of this very entry claimed `charset` affects whether character
    codes render as normal text versus symbol/dingbat glyphs, which was itself
    inaccurate (corrected again, still by external review, not this project's own
    testing). Kept anyway, for the same "one dispatcher, nothing left out to
    re-litigate" reason as everything else here.
  Verified directly against real generated XML before implementing: `family`/`charset`
  use a numeric `val` (`<family val="2"/>`, `<charset val="1"/>`), `scheme` uses a
  string enum `val` (`<scheme val="minor"/>`) - added as `font_family:`/`charset:`/
  `font_scheme:` (descriptive names, matching the existing `font:`/`underline:`/
  `vertical_align:` convention rather than the raw XML tag names).
  - **A test assertion for the cell-level font fallback needed a correction while
    verifying this**: `caxlsx`'s own default font entry (`fontId` 0) already includes
    `family val="1"`, confirmed directly against real generated `styles.xml` - so
    `expected_plain_run`'s baseline needed `font_family: 1`, not `nil`, the same
    "every fixture here already has real values, not an absence" lesson as the
    Arial/11pt default font itself.
- **`background_color` collapsed every fill *other than* a solid one to `nil`,
  indistinguishable from a genuinely unfilled cell - a non-solid pattern fill
  (stripes/hatching) and a gradient fill both lost real information this way.**
  Confirmed with the user before changing the shape (the same design-fork process as
  the cell-font fallback earlier): `background_color` now resolves to
  `{ pattern_type:, fg_color:, bg_color: }` for *any* non-`none` `<patternFill>`
  (`solid` included, for consistency - previously a bare color Hash, now nested under
  `pattern_type: :solid`), both colors captured (not just `fgColor` - a non-solid
  pattern's visible appearance is a genuine two-color mix), and `{ pattern_type:
  :gradient }` for a `<gradientFill>` - a minimal marker, not the actual stops/angle/
  path (a materially bigger feature: multiple color stops, a shape/direction to
  interpret, confirmed with the user as explicitly *not* part of this round). Only
  `patternType="none"` (the default for virtually every cell) or the attribute
  entirely absent still resolves to `nil` - the one case that's actually "no fill" at
  all. Verified directly against hand-built `<patternFill patternType="darkGray">`
  (with distinct `fgColor`/`bgColor`) and `<gradientFill>` fixtures - `caxlsx` has no
  API for either, so both were hand-assembled with `rubyzip` directly, the same
  technique as every other OOXML shape it can't produce.
  - Every existing spec asserting a solid fill's `background_color` needed updating to
    the new nested shape - not a sign of anything wrong, the direct and expected
    consequence of the shape change, the same as the cell-font-fallback round's
    `expected_plain_run` updates. One test's own fixture (`caxlsx`'s `add_style
    bg_color:`) turned out to set an identical `bgColor` alongside `fgColor`, not leave
    it absent - confirmed directly rather than assumed, so the corrected assertion
    reflects what the file actually contains, not a guess.

### Rich text - a fifth external review round: scheme="none" and stale documentation

- **`<scheme val="none"/>` came back as a truthy `:none` symbol, contradicting the
  documented `nil`/`:major`/`:minor` contract - the exact same class of mistake
  `<u val="none"/>`/`<vertAlign val="baseline"/>` were already fixed for, just not
  caught for `scheme` in the same pass.** `"none"` is `scheme`'s own explicit "not
  using a theme font" spelling, same idea as the other two. Verified directly before
  fixing: a run with `<scheme val="none"/>` and nothing else came back
  `font_scheme: :none`. Fixed the same way as the other two - a `NO_FONT_SCHEME_VALUES
  = %w[none]` check, leaving `font_scheme` at its `nil` default rather than assigning
  a symbol for it.
- **Two rounds of run/color-shape changes landed without the accessor's own doc
  comment being updated to match, even though README.md and REQUIREMENTS.md both
  were - found by an external review, not this project's own testing.**
  `rich_text_header_value`'s comment still listed run keys stopping at `condense:`/
  `extend:` (missing `font_family:`/`charset:`/`font_scheme:`, added the round
  before this one) and still described `background_color` as a bare color Hash
  sharing `color`'s exact shape (rewritten two rounds ago to the nested
  `{ pattern_type:, fg_color:, bg_color: }` / `{ pattern_type: :gradient }` form). A
  caller reading only the accessor's own comment - not README.md or REQUIREMENTS.md -
  would have written `background_color[:rgb]` and silently gotten `nil`. Rewritten to
  match current behavior exactly; also caught and fixed the same staleness in
  REQUIREMENTS.md's own "A `color`/`background_color` Hash exposes..." sentence,
  which still claimed `background_color` itself has that flat shape, contradicting
  the correctly-updated bullet ten lines above it describing the new nested one.

### Rich text - a sixth external review round: canonical shape completeness and coverage

- **REQUIREMENTS.md's own canonical `runs` shape (the first place a reader sees it)
  still stopped at `condense:`/`extend:`, even though a paragraph further down already
  documented `font_family`/`charset`/`font_scheme` in full - found by an external
  review, not this project's own testing.** Same underlying gap as the accessor's own
  stale comment fixed the round before this one: one fact, updated in some places but
  not the first/most-visible one. Fixed both the canonical shape and the separate
  "falls back to its own cell style's font" bullet, which listed the fallback's own
  property set incompletely the same way.
- **The cell-style fallback (a plain cell's single run, sourced from `font_for`
  instead of any `<rPr>`) had a spec for `font_family` but none for `charset`/
  `font_scheme` - meaning a regression in `StylesHandler#font_for` or
  `RichTextExtractor#apply_cell_font_fallback` specifically losing either of those two
  properties could pass despite 100% line coverage, since the *run-level* specs for
  `charset`/`font_scheme` exercise a completely different code path
  (`apply_formatting_property` called directly on a run's own `<rPr>`, never through
  the fallback).** `caxlsx`'s cell-style `Font` class (verified directly against its
  source - `lib/axlsx/stylesheet/font.rb`) has a `charset=` setter but no `scheme=` at
  all (only its separate `RichTextRun` class, used for actual rich-text runs, supports
  `scheme`) - so `charset` was addable to the existing fallback spec via `add_style`,
  but `font_scheme` needed a hand-built `styles.xml`, the same technique already
  established for every other OOXML shape `caxlsx` can't produce.
- **`charset`'s documented explanation was itself inaccurate, corrected a second
  time** - per Microsoft's own documentation, OOXML run text is always Unicode
  regardless of `charset`; both `charset` and `family` are font-*matching*/
  substitution hints (which physical font to pick as a replacement when the named one
  isn't installed), not directives that change how a run's own character codes are
  interpreted or displayed the way an earlier version of this same explanation
  claimed (the "symbol/dingbat glyphs" framing). Corrected in the source comment,
  REQUIREMENTS.md, and this file - `scheme` remains the one of the three that
  genuinely determines what actually renders, unchanged from the previous round.

## Primary key handling - design reasoning

**The first framing of this was wrong: `allow_primary_key_write` was originally going to
gate whether the primary key could be *mapped in `required_headers` at all* - that's not
right.** Blocking the mapping entirely conflates two different things: using the primary
key to *look up* an existing row (always safe - it never writes anything new) and using
it to *insert* a new row with a caller-supplied value (the actually risky operation, since
a client-supplied integer id can collide with a future auto-generated one). Once separated
this way, `raw_upsert_all`/`activerecord`/`activerecord_import` never need a config-time
block at all - they already have a lookup step, so the protection can be enforced
per-row, at the not-found branch, at runtime. Only `raw_insert_all`/`raw_copy` still need
the blanket config-time block, and not as a special case of the same rule - they have no
lookup step at all, so for them there's no "safe, read-only" use of the primary key to
carve out in the first place; every use is a write.

**A separate `on_missing_primary_key` (`:raise`/`:insert`) macro was designed, then
dropped as redundant.** The original idea was a schema-driven default - auto-detect
whether the primary key column auto-increments (via its `default_function`: `nextval(...)`
family vs. a client-supplied default like `gen_random_uuid()` vs. none at all) and default
to `:raise` for the risky auto-increment case, `:insert` otherwise, overridable per
subclass. Once `allow_primary_key_write` was reframed as the write-gate (above), this
whole second axis turned out to be redundant: `allow_primary_key_write`'s `true`/`false`
already fully determines raise-vs-insert on a not-found lookup on its own - `false` means
writing a new row with a caller-supplied id isn't allowed at all, so not-found has to
raise; `true` means it's explicitly allowed, so not-found just inserts. No schema
auto-detection needed, no second macro, one knob instead of two - consistent with every
other v1 simplification in this file (e.g. the rich-text batching decision above).

**Why `raw_upsert_all` and `activerecord_import` need a new pre-batch existence guard,
but `activerecord` doesn't.** `activerecord` already calls `find_or_initialize_by` once
per row before deciding to insert or update - "was this found?" is already known, for
free, before any write happens. `raw_upsert_all` (`upsert_all`) and `activerecord_import`
(the gem's `import`) instead build one bulk `INSERT ... ON CONFLICT DO UPDATE` statement
covering an entire batch at once - Postgres resolves found-vs-not-found per row inside
that single statement, but Ruby never sees the distinction beforehand. So enforcing
"raise if not found" for these two modes needs an explicit pre-batch check (`SELECT` the
primary keys already present in the batch, same shape as the existing
`assert_no_duplicate_unique_by_values!` guard) run *before* the bulk statement, to filter
out and log any row whose id doesn't match an existing record. This guard is only needed
when `allow_primary_key_write` is `false` - when `true`, a not-found row is supposed to
insert anyway, which the bulk statement already does correctly with no help needed.

## Primary key handling - implementation-time findings

Two more things were verified empirically while actually building this, on top of the
design reasoning above - both change how omitting a blank primary key had to be
implemented, not just what it does.

- **`insert_all!`/`upsert_all` raise `ArgumentError: All objects being inserted must have
  the same keys` if the hashes in one call don't all have identical keys.** Reproduced
  directly: one hash with an `:id` key and another without it, passed to `upsert_all` in
  the same call, raises this immediately - and it's a plain `ArgumentError`, not
  `ActiveRecord::StatementInvalid`, so `write_batch_with_row_isolation`'s existing rescue
  doesn't catch it at all; it would propagate straight out of `import!` uncaught. Since a
  blank primary key's attribute is deliberately omitted from that row's hash (see the
  design section above) while a provided one keeps it, any batch mixing blank and
  non-blank primary key values for `raw_insert_all`/`raw_upsert_all` hits this
  immediately. Fixed by splitting a batch into one sub-batch per key-shape
  (`partition_by_primary_key_presence`) before ever calling the writer - confirmed a
  batch where every row *consistently* omits the key works fine on its own, so the
  problem is specifically heterogeneous keys within one call, not omission itself.
  `activerecord_import` doesn't have this problem: verified empirically that the
  `activerecord-import` gem's `Model.import` builds its `INSERT` from each model
  instance's own attributes (always a complete, uniform set per model class, regardless
  of what was passed to `.new`), not from a shared hash-key list the way a raw
  `upsert_all` call is - a batch of instances mixing an explicit `id` on some and none on
  others imports correctly with no splitting needed.
- **`find_or_initialize_by({})` matches an arbitrary existing row, not "no row."**
  Reproduced directly against a table with two existing rows: `Post.find_or_initialize_by({})`
  returned an existing record (`new_record?` false) - Rails builds `WHERE` from the hash
  as given, and an empty hash means no `WHERE` clause at all, so it's equivalent to
  `Post.first`. This matters because `build_activerecord_record`'s existing
  `attrs.slice(*@unique_by_columns)` call would produce exactly this empty hash whenever
  `unique_by` resolves to the primary key and that row's primary key was blank (the key
  omitted from `attrs` entirely, per the design above) - silently "updating" a random
  unrelated record instead of inserting a new one, with no error to signal it. Fixed by
  checking for this exact combination (`@unique_by_columns == [primary_key_attribute]` and
  the key missing from `attrs`) before ever calling `find_or_initialize_by`, and building
  a fresh record directly instead in that case.
- **`connection.indexes` never includes the primary key's own index.** Reproduced
  directly: `Post.connection.indexes(Post.table_name)` lists only the declared unique
  index on `slug`, nothing for `id` at all - Postgres represents a primary key as a table
  constraint, and Rails' index introspection deliberately excludes it from the regular
  index list it returns. `assert_unique_by_valid!` searches exactly that list, so
  `unique_by :id` would otherwise always fail with "no unique index found", even though a
  primary key is definitionally unique. Fixed by resolving `unique_by :id` (or whatever
  `target_model.primary_key` actually is) directly, without searching `connection.indexes`
  at all, and only falling through to the index search for every other `unique_by` value.

## Merge detection - three bugs found by an external review

None were caught by this project's own testing at the time - the existing specs only
ever exercised a horizontal, two-cell merge on the workbook's only sheet (`"A1:B1"`),
which happens to sidestep all three problems below.

- **A vertical (single-column) merge like `"A1:A2"` left its own anchor row undetected,
  so a header row that's the anchor of one evaded the header-row check entirely.**
  Verified directly: for `"A1:A2"`, only row 2 (the non-anchor cell, `A2`) was ever added
  to the tracked set - row 1 (the anchor, `A1`, which genuinely keeps its value and isn't
  blanked) was deliberately excluded, by design at the time. But this meant a file with
  `header_row 1` and a vertical merge `"A1:A2"` never raised via the header check at all -
  reproduced directly end-to-end. It happened to still raise in that specific
  reproduction, via the *data-row* check catching row 2 instead (misattributing the
  problem to the wrong row) - but only because row 2 fell within the range
  `each_excel_row_number_and_values` actually iterates; a `data_start_row` configured to skip past row 2
  (a legitimate, already-supported configuration for skipping decorative rows) would have
  let it through with no error anywhere. Fixed by dropping the anchor/non-anchor
  distinction entirely: every row from a merge's start to its end is now tracked, anchor
  row included. This isn't a loss of precision worth preserving - verified directly that
  a *horizontal* merge's anchor row already has a real non-anchor cell in it (in one of
  its other columns), so "the anchor row is safe" was never actually true across merge
  shapes in the first place, only for the single-column case, and this class already
  treats a merge as an unconditional error rather than trying to distinguish exactly
  which cell within a row is the problem.
- **The handler expanded every `(row, column)` pair in a merge range into its own array
  entry before ever reducing to row numbers - unbounded by anything this class controls.**
  A merge spanning many columns and many rows multiplies the two dimensions together in
  memory for information only ever consumed at row granularity. Verified directly: a
  50-column x 20,000-row merge (1,000,000 cells) processed in ~6ms after the fix,
  tracking exactly 20,000 Set entries (row numbers) - never allocating a single per-cell
  entry at all. Fixed by extracting only each range's start/end row and adding every row
  in between directly to a `Set`, with `Roo::Utils.extract_coordinate`'s column value
  simply discarded (`start_row, = extract_coordinate(...)`) rather than computed and
  then thrown away downstream.
- **`excel_sheet_xml_path` always resolved to sheet 1's XML, regardless of `sheet_name`
  - merge detection never actually looked at the selected sheet at all.** Verified
  directly, on a real two-sheet workbook: `excel_workbook.sheet_for(name).sheet_files`
  returned the *identical* path for both `sheet_for("FirstSheet")` and
  `sheet_for("SecondSheet")` - it delegates to a shared, workbook-wide object rather
  than anything sheet-specific (this project's own testing at the time only ever used
  single-sheet fixtures for the merge-detection specs, which can't surface a bug that
  only shows up with more than one sheet in play). The practical consequence cuts both
  ways: a merge in a *non-first* sheet went completely undetected (the exact
  silent-blanked-cell failure this whole feature exists to catch, now reachable via
  multi-sheet files specifically), while a merge sitting in an unused first sheet could
  raise spuriously for a sheet never even being read. Fixed by indexing into the
  top-level `excel_workbook.sheet_files` (verified directly to return the full,
  correctly-ordered list for every sheet in the workbook) by the selected sheet's
  position in `excel_workbook.sheets` - verified directly that this resolves to that
  sheet's own XML, containing that sheet's own `<mergeCells>` and no one else's.

## `exclude_row?` reading stale row data - found while designing rich-text access

Noticed (not yet fixed) during the rich-text work: `raw_value_for`/`raw_header_value`/
`rich_text_header_value` all read `@current_row`/`@current_line_number`, but those two
ivars were set only inside `Importer::Base#build_attributes` - which doesn't run until
*after* the row loop has already called `exclude_row?(row)` and gotten `false`
back. So any of those three accessors called from inside an `exclude_row?` override would
read stale data: whatever row was processed *previously*, or `nil` for the very first row
- never noticed in practice only because the one existing example
(`PostActiveRecordImporter#exclude_row?`) reads `row['hey']` directly instead of
going through these methods.

Verified directly, via `bin/rails runner` against a real CSV importer whose
`exclude_row?` called `raw_header_value('Status')` instead of `row['Status']`: temporarily
reverting the fix below (`git apply -R` against the diff) reproduced exactly the predicted
failure - `NoMethodError` on `nil['Status']` on the very first row, since `@current_row`
was still `nil` at that point (the loop's `exclude_row?` for row 1 runs before
`build_attributes` for row 1 ever does). Reapplying the fix and rerunning the same script confirmed
`raw_header_value('Status')` now returns the *current* row's value on every row, including
the first.

Fixed by moving `@current_row = row` / `@current_line_number = line_number` out of
`build_attributes` and into the top of the per-row block, before the `drop_blank_rows`
check and the `exclude_row?` call - so both ivars are always current by the time
`exclude_row?` runs, the same as they already were by the time a `cast_<attribute>`
override runs. `build_attributes`'s own assignment became redundant once that block
(which always runs first, for every row, regardless of format) set both ivars itself, so
it was removed there rather than left duplicated.

That block was `Importer::Concerns::Hooks#process_row` at the time. In 2.0.0 it was
dissolved into `Importer::Base#import!`'s own row loop - it straddled the parser/loader
split, doing business logic (`drop_blank_rows`, `exclude_row?`) from inside what became
the parsers' streaming loops. **The ordering above is exactly what that loop still does,
and is still load-bearing for the same reason**: set both ivars first, then the blank
check, then `exclude_row?`. Both parsers' `each_row` now yield unconditionally and
decide nothing.

## A `:decimal` column's scale was silently rounding away real digits, not raising

Prompted by a specific question about currency values: what actually happens when a
value has more fractional digits than a `:decimal` column's declared `scale` allows -
e.g. a `decimal(6,2)` column given `123.4567`? The concern was real - verified directly,
before any fix, against a genuine `decimal(6,2)` Postgres column, for both a native Excel
`Float` cell and a CSV/text string:

```
Roo native value: 123.4567 (Float)
=== :raw_insert_all mode ===
Stored amount: 0.12346e3   # 123.46 - the .67 gone, no error, no log entry
=== :activerecord mode ===
Stored amount: 0.12346e3   # identical result via the model-assignment path
```

Root cause: this class's own cast pipeline (`Importer::RowTransformer`) never checked
scale/precision at all - `default_cast` only ever validated a value's *type* (is it a
`Numeric`? a `Date`?), never how many digits a `:decimal` column's `scale` allows. A
native Excel `Float` passed `native_type_match?(:decimal, value)` (it's `Numeric`) and
was returned completely untouched from `resolve_cast`; a parsed CSV string produced a
`BigDecimal` the same way, also with no scale check. The actual rounding happened
entirely downstream, in `ActiveRecord::Type::Decimal#cast` (whatever eventually calls
it - `insert_all!`/`upsert_all`'s own value serialization, or a plain model attribute
assignment in `:activerecord` mode) - verified that this rounds silently to the column's
`scale` with no exception at all, for either write path identically. This directly
contradicted the reasoning already documented in base.rb's "Casting" section - this
whole pipeline exists specifically because ActiveRecord's own casters are silently lossy
- but that guarantee had only ever been built out for *type* mismatches (a bad string
casting to `0`, an unparseable date to `NULL`), never for a value that's the right type
but exceeds the column's own `scale`.

Fixed by adding `Importer::RowTransformer#cast_decimal`, given every `:decimal`-typed
attribute regardless of whether its raw value arrived as a native `Numeric` or a `String`
needing to be parsed first: it builds the `BigDecimal` either way, then compares it
against `value.round(type_metadata.scale)` - a mismatch means real digits would be lost,
so it raises instead of returning. `type_metadata.scale` (from
`target_model.type_for_attribute(attribute).scale`) is `nil` for a `:decimal` column
declared with no explicit scale (arbitrary precision) - verified directly - so this never
raises for one; there's no fixed scale to have exceeded. Re-verified after the fix, same
reproduction as above: both `:raw_insert_all` and `:activerecord` mode now raise
`Importer::Base::ImportError: ... has more decimal places than this column's scale of 2
allows ...` instead of silently storing `123.46`.

## Exposing the written primary key value on after_batch - two rounds

### Round 1: position-based (RETURNING/gem backfill) - shipped, then found unsafe

Prompted by a specific need: knowing, after a row is actually written, which real DB
primary key it became - regardless of mode, and regardless of whether the file even
provided a primary key at all (a row could just as easily be looked up/upserted by a
natural key, e.g. `unique_by :slug`).

First implementation matched a written row back to its primary key by *position*:
`insert_all!`/`upsert_all` (`raw_insert_all`/`raw_upsert_all`) already return the
primary key via Postgres `RETURNING` by default, and `activerecord-import`
(`:activerecord_import`) backfills each record's own primary key onto that same
instance automatically - both read purely by index into the write's own result, in the
order rows were submitted. Verified directly at the time (5 trials of an 8-row
`insert_all!`, cross-checked against the DB's own slug-per-id mapping; `upsert_all`
with a conflicting row confirmed to get the *pre-existing* record's real id back, in
the same input position) that this held up empirically.

**An external review correctly rejected this as unsafe, twice:**
- **P1**: relying on `RETURNING`'s row order matching input order is not a documented
  guarantee. PostgreSQL's own mailing list has an actual 2012 patch proposal
  ("[PATCH] Enforce that INSERT...RETURNING preserves the order of multi rows") to make
  this official - discussed, never adopted. The official docs
  ([`dml-returning.html`](https://www.postgresql.org/docs/current/dml-returning.html))
  say nothing about order either way - silence, not a guarantee. Checked what this means
  in practice: `activerecord-import` (2.2.0, this app's own installed version) relies on
  the *identical* positional assumption for its own PK backfill -
  `set_attributes_and_mark_clean` in `lib/activerecord-import/import.rb` does
  `import_result.ids.each_with_index { |id, index| models[index].id = id }` - so
  `:activerecord_import` was never actually safer here, just carrying the same risk
  inside a dependency. Documenting the risk more prominently (what was tried first) does
  not fix it - a caveat isn't a fix for a mechanism that can silently misattribute a
  row's real database identity, which directly contradicts this class's own founding
  principle (see base.rb's "Casting" section - never silently lose or misattribute
  data). The review's own words: "another dependency making the same assumption does not
  make it safe."
- **P2**: cross-database claims made at the time were also wrong or incomplete, found by
  reading actual adapter/gem source, then confirmed by running all four modes directly
  against this app's real `wordpress:` (mysql2, genuine MySQL 8.4.5, not MariaDB)
  connection:
  - `raw_insert_all` degraded safely (key genuinely absent) - as documented.
  - `:activerecord` populated real ids - as documented (never depended on `RETURNING` to
    begin with).
  - `:activerecord_import` set `:primary_key_value` to a **present `nil`** - the key
    existed on the Hash with a `nil` value, not absent as the docs claimed. Root cause:
    the old code always wrote `batch[index][:primary_key_value] = record.public_send(pk)`
    for every non-failed record, with no check for whether the gem's backfill had
    actually run.
  - `raw_upsert_all` was documented as working on "MariaDB 10.5+" for `RETURNING` - true
    for `RETURNING` alone, but irrelevant: `raw_upsert_all` always declares `unique_by`,
    which requires `supports_insert_conflict_target?` - verified in Rails 8.1.3's own
    source (`abstract_adapter.rb`) that this defaults to `false` and is only overridden
    in `postgresql_adapter.rb`/`sqlite3_adapter.rb` - **not** in
    `abstract_mysql_adapter.rb` at all, for either MySQL or MariaDB. So `raw_upsert_all`
    cannot run on MariaDB either - it raises `ArgumentError: ... does not support
    :unique_by` immediately, regardless of `RETURNING` support. Confirmed directly
    against the real `wordpress:` connection.

### Round 2: value-based resolution - the actual fix

Discussed with the user (in Cantonese) and agreed: stop relying on `RETURNING`/the
gem's positional backfill entirely. Resolve `:primary_key_value` by **value**:

1. **The row's own attrs already include the primary key** (`allow_primary_key_write
   true`, caller supplied it directly) - use it directly, no query.
2. **Else, `unique_by` is declared** - one extra query per batch (not per row):
   `target_model.where(unique_by_columns.first => values).pluck(*unique_by_columns, pk)`
   - verified directly this returns proper per-row tuples - then match each candidate
   back by its own *full* tuple, never by position in the query's result (order is
   irrelevant to a value match). Verified this is correct for both a fresh insert and a
   row that updated an *existing* record via `unique_by`: the query runs after the
   write, so it reports whichever id currently exists for that natural key either way -
   no special-casing needed. `raw_upsert_all` always has `unique_by` (mode
   requirement), so this path is always available there.
3. **Else** - not populated. No natural key, no supplied primary key, nothing to
   reliably correlate by - this class does not report an unverified guess.

**A null-collision edge case, found while designing this, not before shipping it**: if
`unique_by` allows nulls (Postgres's default, "nulls distinct" - confirmed via this
codebase's own widgets test tables, added with no `nulls_not_distinct` option) and more
than one row in a batch shares the same `unique_by` value (most commonly more than one
`NULL`), value-based matching is genuinely ambiguous for those specific rows - the query
returns more than one DB row for that one key, and there's no way to tell which
generated id belongs to which. Handled by detecting the collision on *both* sides
(`assign_primary_key_values_by_unique_key!` in `loaders/base.rb`: more
than one DB row sharing a key, or more than one batch item sharing a key) and leaving
`:primary_key_value` unset for exactly those rows - everything else in the same batch
still resolves normally.

**Re-verified against the real `wordpress:` MySQL connection after the fix** (the exact
same reproduction used to find the P2 bug): `raw_insert_all` (with `unique_by`),
`:activerecord`, and `:activerecord_import` all now correctly populate
`:primary_key_value` there - not just "safely absent" as before, but actually correct,
since a plain `SELECT`/`pluck` needs no `RETURNING` or gem-specific adapter support at
all. `raw_upsert_all` still can't run on MySQL/MariaDB at all (confirmed again: raises
immediately, `unique_by` itself unsupported) - unchanged, a limitation of the mode
itself, not of this resolution mechanism.

**Known, honestly-documented limitations of the new mechanism (real, not eliminated)**:
1. `raw_insert_all` with neither `unique_by` nor an explicit primary key ("blind bulk
   insert") never gets `:primary_key_value` - a real narrowing from round 1's (unsafe)
   behavior, accepted deliberately rather than guessed around.
2. One extra `SELECT` per batch whenever the `unique_by` path is used.
3. The null-collision case above.

Implemented as `Importer::Loaders::Base#resolve_primary_key_values!` (shared
by all three affected modes) plus `assign_primary_key_values_by_unique_key!` (the
`unique_by` lookup itself). `loaders/row_isolatable.rb#write_batch_with_row_isolation`
and `loaders/activerecord_import.rb#write_batch` both call the shared
resolver instead of reading anything from `RETURNING`/the gem's own backfill.
`loaders/plain_record.rb` (`:activerecord`) is unchanged - `record.public_send(pk)` right
after that same object's own `save!` was never a position/correlation problem to begin
with.

## `on_row_skip` missing entirely from a third skip path - found by an external review

`Importer::Loaders::Base#reject_missing_primary_key_rows!` (enforces
`allow_primary_key_write false`'s protection for `raw_upsert_all`/`activerecord_import`,
the two modes with no per-row lookup step) already logged an error and incremented
`@skipped_count` under `on_failure :skip`, but never called `on_row_skip` at all - a
third, separate skip path neither `loaders/plain_record.rb#handle_row_failure` nor
`loaders/activerecord_import.rb#handle_activerecord_import_failures` covers, missed
entirely when `on_row_skip` was first added (both of those were the only two call sites
checked at the time).

Verified directly, identical config reproduced against both modes that can actually
reach this method's `:skip` branch at runtime (`raw_upsert_all` is also a caller, but
`on_failure :skip` can never be configured there at all -
`assert_on_failure_supported!` rejects it at config time - so its own `:skip` branch here
is unreachable for that mode, not a second silent gap):

```
mode=activerecord: on_row_skip calls=[{line_number: 2, attrs: {...}, message: "no existing ... allow_primary_key_write is false"}]
mode=activerecord_import: on_row_skip calls=[]
```

`:activerecord` already worked correctly here because its equivalent check lives inline
in `write_row_activerecord`, going through the same `handle_row_failure` every other
per-row failure there does. `:activerecord_import`'s version of this check is the
separate, shared `reject_missing_primary_key_rows!` instead, which had never been
updated to call the hook. Fixed by calling `on_row_skip` for each rejected row inside
that method's own `on_failure == :skip` branch, reusing the same message already built
for `log_error` rather than duplicating the string. Re-verified after the fix: both
modes now produce an identical `on_row_skip` call for the same row.

## `raw_upsert_all` trusted a stale caller-supplied primary key - found by an external review

`resolve_primary_key_values!`'s step 1 (trust `attrs[pk]` directly when the row's own
attrs already included it) assumed that value was always what actually got written.
True for `raw_insert_all` (a conflict there just raises, never silently keeps an old
value) and for `activerecord_import` (confirmed: the gem's own upsert *does* write a
caller-supplied id on conflict) - but not for `raw_upsert_all` when `unique_by` is some
other natural key, not the primary key itself. Rails' `upsert_all` excludes the primary
key from its own `DO UPDATE SET` whenever the conflict target is something else - the
existing row's real, pre-existing primary key is what stays, never the caller-supplied
one for that same (conflicting) row.

Reproduced directly before fixing: existing row `id: 1, name: 'clash'`; CSV row
`id: 99999, name: 'clash', quantity: 7` under `unique_by :name`,
`allow_primary_key_write true`. After import, the row was still `id: 1` (every other
column, `quantity`, updated correctly - only the primary key itself was left alone, as
`DO UPDATE SET` excludes it) - but the old step 1 reported `primary_key_value: 99999`
anyway, since it never checked whether that value was actually written.

Fixed by not trusting `attrs[pk]` directly for exactly this one combination
(`self.class.mode == :raw_upsert_all && @unique_by_columns != [primary_key_attribute]`)
- falling through to step 2 instead, which resolves it correctly via the natural key
(`unique_by`) rather than the never-written primary key. Re-verified after the fix:
same reproduction, `primary_key_value` now correctly reports `1`.

## `:activerecord_import` + `unique_by` on MySQL - one bug fixed, one found unfixable

Verifying `:primary_key_value`'s cross-database claims meant testing directly against
this app's real `wordpress:` (mysql2, genuine MySQL 8.4.5, not MariaDB) connection - not
just reasoning about adapter source. This surfaced two *separate* problems stacked on
top of each other, only the first of which turned out to be fixable.

**Problem 1 (this class's own bug, fixed): `activerecord_import_upsert_option`
(`loaders/activerecord_import.rb`) always built the PostgreSQL/SQLite-shaped option,
regardless of adapter.** Confirmed by reading the gem's own adapter source, not
assumed: `lib/activerecord-import/adapters/postgresql_adapter.rb` expects
`{conflict_target:, columns:}` (`sql_for_conflict_target` reads `args[:conflict_target]`
directly - exactly the shape always built, unconditionally, before this fix), while
`lib/activerecord-import/adapters/mysql_adapter.rb` expects a plain column `Array` (or a
`{col => col}` `Hash`) instead, with no `conflict_target` key at all - MySQL's
`ON DUPLICATE KEY UPDATE` isn't scoped to a specific index the way `ON CONFLICT` is, so
it needs no conflict target. Fixed by branching on
`connection.supports_insert_conflict_target?` (Rails core, already established as the
right discriminator earlier - see the RETURNING-order section - and confirmed necessary
directly *again* here: this app's own primary connection reports `adapter_name`
`"PostGIS"`, not `"PostgreSQL"`, so a literal adapter-name string match would have been
wrong for this app's own database).

**Problem 2 (a genuine `activerecord-import` gem defect, confirmed unfixable from this
class's side): even with the correct option shape, MySQL still didn't upsert.** Traced
further: the gem only builds an `ON DUPLICATE KEY UPDATE` clause at all when
`connection.supports_on_duplicate_key_update?` is true. The gem *does* have a proper
MySQL implementation of this (`ActiveRecord::Import::MysqlAdapter`, mixed in via
`ActiveRecord::Import::Mysql2Adapter`, which would return `true`) - but confirmed
directly that this extension never actually gets mixed into
`ActiveRecord::ConnectionAdapters::Mysql2Adapter` under this app's installed Rails
8.1.3 + activerecord-import 2.2.0 (the latest published version - no newer release to
upgrade to): `connection.class.ancestors` shows only the gem's own generic
`ActiveRecord::Import::AbstractAdapter::InstanceMethods` fallback, whose
`supports_on_duplicate_key_update?` hardcodes `false`. No option shape passed from our
own code can work around this - the gem never reaches the code that would use it. This
is a defect in the gem's own adapter-loading mechanism, not anything
`activerecord_import_upsert_option` controls.

**Response, per the user's direction:** rather than leave this as a confusing runtime
surprise (a raw `Mysql2::Error: Duplicate entry`, exactly as if `unique_by` had never
been declared), added `assert_upsert_supported!`
(`loaders/activerecord_import.rb`, called from its own constructor) - raises at config time,
specifically for `:activerecord_import` with `unique_by` declared against a connection
`supports_on_duplicate_key_update?` reports `false` for, pointing at `:activerecord`
mode as the working alternative. Scoped narrowly on purpose, confirmed with the user
first: a plain insert via `:activerecord_import` (no `unique_by`) already works
correctly on MySQL (verified directly - `primary_key_value` resolved correctly there
too), so the guard only blocks the specific combination that's actually broken, not the
whole mode.

## A `:decimal` column-adjacent, second Ruby-vs-database-equality gap - documented, not fixed

Separately, verifying `resolve_primary_key_values!`'s cross-database behavior surfaced
one more real, but out-of-scope-to-fully-fix, gap: **value-based matching in
`assign_primary_key_values_by_unique_key!` uses Ruby's own equality, not the
database's.** If a `unique_by` column's collation makes the database compare values in
a way Ruby's `==` wouldn't (case-insensitively, e.g.), matching can miss a row that was,
in fact, found and correctly written by the database itself. Reproduced directly
against a Postgres column with an explicit case-insensitive ICU collation: existing row
`name: 'WIDGET-UPPER'`, CSV row `name: 'widget-upper'` under
`raw_upsert_all`/`unique_by :name` - the conflict update applied correctly (`quantity`
updated on the *existing* row, id unchanged) - but `:primary_key_value` was left
entirely unset, since the query's returned tuple (`["WIDGET-UPPER"]`, the stored value)
never equals the batch item's own attrs tuple (`["widget-upper"]`) under Ruby's exact
string equality. Safe (no wrong value reported - consistent with this class's core
principle), but a real completeness gap. Not fixed: doing so properly would mean
pushing the whole match into SQL itself (a significantly more invasive change) for what
is, in practice, a rare column configuration - most `unique_by` columns are plain
case-sensitive strings or numeric/date values, where Ruby equality and the database's
own comparison agree.

## The transaction-connection bug, found the same way - fixed

Also found while stress-testing against the real `wordpress:` connection: every
transaction in this class (`base.rb`'s own `import!`, `loaders/row_isolatable.rb`
(twice), `loaders/activerecord_import.rb`, `loaders/plain_record.rb`) opened on
`ActiveRecord::Base.transaction(requires_new: true)`, never on
`self.class.target_model.transaction(...)`. For a `target_model` on any connection other
than whatever `ActiveRecord::Base` itself defaults to (this app's own `Wordpress::Record`,
or - confirmed with the user this isn't MySQL-specific - equally, a second Postgres
database via `connects_to`, e.g. this app's own `queue:`/`cable:`/`cache:` connections),
this wrapped the *wrong* connection entirely.

Reproduced directly, before fixing: forced an `after_batch` exception against a
`wordpress:`-connected model. The row **stayed committed** despite the exception
propagating - because the actual `INSERT` ran on the `wordpress:` connection, never
actually inside the transaction `ActiveRecord::Base.transaction` opened (on a
different, uninvolved connection). This broke the "the whole run is one transaction,
any failure rolls back everything" guarantee this class states throughout its own
docs, for any subclass whose `target_model` isn't on `ActiveRecord::Base`'s own
default connection - not a hypothetical gap given `Wordpress::Record` already exists
in this app.

Fixed by replacing `ActiveRecord::Base.transaction(...)` with
`self.class.target_model.transaction(...)` at all five call sites - one import always
writes to exactly one connection, never two at once, so `target_model`'s own connection
is always the right (and only) one to wrap; no multi-database transaction coordination
is ever actually needed. Re-verified after the fix, same reproduction as above: the row
against the `wordpress:`-connected model is now correctly rolled back. Regression specs
pin the fix down via a message expectation on `target_model.transaction` (this spec
suite's test environment only configures one real database connection besides
`wordpress:`, so a true cross-connection reproduction the way this was originally found
isn't practical to keep as an automated spec - the manual verification above is that
proof) for all four modes.

## `raw_insert_all` skip-and-continue - design reasoning

Considered and decided against, not something still open: `raw_insert_all`'s Modes entry
marks "fail and skip" ❌. `isolate_failing_rows` already isolates which rows in a failed
batch are the bad ones, which made extending it to keep the good ones and log-and-continue
past the bad ones look like a small step at first. On reflection, it's a bigger change
than that framing suggests, for two reasons specific to this mode:

1. It only becomes possible for a batch by falling back to one INSERT per row for that
   whole batch (the retry loop) - for a batch of 1000 with even a single bad row, that's
   1000 round-trips instead of 1. Every dirty batch pays this cost, which cuts against
   the entire reason to reach for `raw_insert_all` over `activerecord_import` in the
   first place (speed).
2. It requires giving up the single all-or-nothing transaction this mode currently
   relies on - skip-and-continue means rows/batches that succeeded need to actually stay
   committed even though other rows failed, which is a different transaction model, not
   an extension of the current one.

`activerecord_import` already gets skip-mode close to free (`failed_instances`, no
per-row fallback needed) precisely because it's already instantiating a model per row -
it doesn't pay a performance cliff for it the way `raw_insert_all` would. Decided with
the user: no need for every mode to support everything - `activerecord_import` already
covers this need, so this isn't pursued for `raw_insert_all`. Not tracked in README.md's
TODO section (nothing left to reconsider); kept here as the record of why, should it ever
come up again.

## `rich_text_header_value` raised for a non-.xlsx import - changed to return nil instead

Found while adding an example importer that demonstrates the whole hook set
(`app/services/importer/post_active_record_importer.rb`): `cast_body` used
`rich_text_header_value` to convert an Excel cell's bold/italic runs into HTML, and
needed its own `excel_file?` guard first, since this importer (like any subclass) can
process a CSV/TSV file just as easily as a `.xlsx` one - `rich_text_header_value` raised
`ImportError: rich_text_header_value is only available for .xlsx imports` otherwise.

Raised, not asked for by name: a review of the example surfaced that this raise is
inconsistent with `raw_header_value`'s own "not found -> nil" convention, and forces
every `cast_<attribute>` override that might run against either format to write that
same guard by hand. A CSV/TSV cell has no rich-text concept to extract in the first
place - "nothing to report" is exactly the same kind of `nil` this method already
returns for a declared header simply missing from a genuine `.xlsx` workbook, not a
different, third kind of `nil` a caller has to keep separate.

Changed `rich_text_header_value` to `return nil unless excel_file?` instead of raising -
kept the *other* raise (a header never declared via `rich_text_headers` at all) exactly
as it was: that's a caller mistake in the subclass's own code, not a per-row/per-format
data question, and deliberately still distinct from every "nothing to report" `nil`
case. Updated the one spec that asserted the old raise
(`base_excel_parsing_spec.rb`) to assert the row imports successfully with `nil`
instead.

This also surfaced two more, adjacent latent bugs in the example's own `cast_body`,
neither hypothetical - reproduced directly before fixing: `rich_text_header_value`
returning a bare `nil` (now for a non-`.xlsx` import too, but already true for a
declared-but-not-found header) crashed `[:runs]` with `NoMethodError`, and a
genuinely blank but real Excel cell (`{ runs: nil, background_color: ... }`) crashed
`.map` the same way. Fixed by reading `&.dig(:runs)` and falling back to the cell's
own plain `raw_value` whenever that's `nil`, covering all three "nothing to convert"
cases (non-`.xlsx`, header not found, genuinely blank cell) with the same one line,
rather than a separate special case for each.

## `file_format` - a new method for a subclass to read back which parser is running

Requested directly: a subclass's `cast_<attribute>`/hook methods had `raw_header_value`
and `rich_text_header_value` to ask about a specific column's *value*, but nothing to
ask the more basic question - which file format (CSV, TSV, or Excel) produced the row
currently being processed at all. The existing `excel_file?` (private, already used
internally to dispatch `verify_headers!`/`each_row`) only ever answered "is this Excel",
which doesn't distinguish `.csv` from `.tsv` - no existing method did.

Added `file_format` to `base.rb`, right next to `excel_file?`: a plain
`File.extname(file_path).downcase` switch returning `:csv`, `:tsv`, or `:xlsx` -
private, but callable via implicit `self` from any subclass instance method, the same
convention every other cast-time accessor (`raw_header_value`, `rich_text_header_value`,
`excel_file?` itself) already follows. `excel_file?` is now defined in terms of it
(`file_format == :xlsx`) rather than re-checking the extension separately, so the two
can never disagree.

No format-validation guard needed inside `file_format` itself: `assert_supported_file_extension!`
already runs first thing in `import!`, before any row is read or any hook/cast method can
possibly execute, so by the time a subclass could call `file_format` the extension is
already guaranteed to be one of the three this class supports - an unmatched `case`
falling through to `:csv` is unreachable in practice, not a silently-wrong default for a
real input.

## `allow_primary_key_write` left a Postgres sequence out of sync - a real, deferred bug

Raised directly: "when [a table uses auto-increment], `allow_primary_key_write` is true,
a new record being inserted - later, when someone in Rails tries to insert a new record,
it may raise error saying the ID is used." Reproduced exactly before building anything:

```
existing rows: [1, 2]                          # sequence at 2
import a row with allow_primary_key_write true, explicit id: 3 (where the sequence is about to land next)
=> row inserted successfully, sequence still at 2 (untouched)

later, unrelated: SomeModel.create!(...)       # normal app code, no explicit id
=> ActiveRecord::RecordNotUnique: PG::UniqueViolation:
   duplicate key value violates unique constraint "..._pkey"
   DETAIL: Key (id)=(3) already exists.
```

Root cause: `insert_all!`/`upsert_all`/`save!` all bypass `nextval()` entirely whenever a
value is supplied directly for the primary key column, regardless of whether that value
ends up higher than the sequence's own current position - true in every one of the 4
implemented modes, since all 4 go through `allow_primary_key_write` to write an explicit
id in the first place. Nothing about the later, colliding `create!` is wrong; the
sequence itself is simply left unaware that a higher id now exists.

Fixed with `connection.reset_pk_sequence!(table_name)` - Rails' own Postgres adapter
method (`:nodoc:`, but a real, long-standing public instance method, not a private API
reach-in - confirmed via `respond_to?(:reset_pk_sequence!, true)` returning `true`, and
via `public_methods.include?`), which resyncs a table's sequence to `MAX(id)`. Verified
directly, same reproduction as above: calling it after the import lets the subsequent
`create!` succeed with the next real id, no collision. Also verified safe to call
unconditionally, in three edge cases:
- **An empty table** - `reset_pk_sequence!` reads the sequence's own `MINVALUE` instead
  of raising when `MAX(id)` is `nil`; confirmed no error.
- **A primary key with no sequence at all (e.g. a UUID column)** - confirmed no error;
  the method itself only acts when a table actually has both a primary key and a
  sequence for it.
- **A non-Postgres adapter** - confirmed by reading Rails' own source
  (`grep -rn "def reset_pk_sequence"` across every `connection_adapters/` subdirectory)
  that this method is defined *only* in `postgresql/schema_statements.rb` - it doesn't
  exist at all on the MySQL adapter, so `connection.respond_to?(:reset_pk_sequence!)`
  naturally gates this to Postgres only, the same "adapter-aware, no-op where not
  applicable" pattern already used for the MySQL upsert gap elsewhere in this class. This
  isn't an oversight left for later: MySQL's own `AUTO_INCREMENT` already self-adjusts
  upward when a row is inserted with an explicit value higher than its current counter -
  a genuine behavioral difference from a Postgres sequence, not something this class
  needs to work around there too.

Wired into `Importer::Base#import!` as `reset_pk_sequence!`
(`Importer::Loaders::Base`), called once, right after the whole run's own
transaction block finishes (not per-batch, not from inside the transaction) - guarded on
`self.class.allow_primary_key_write` alone, no new config macro: that flag is already the
deliberate "I know this is risky" opt-in for exactly this class of danger. Applies to all
4 implemented modes uniformly, since the underlying cause (an explicit PK bypassing
`nextval()`) isn't mode-specific.

**A second, more subtle bug surfaced while writing the regression specs for this - not in
the feature itself, but in how it interacts with this test suite's own existing tests.**
Several pre-existing specs in `base_spec.rb`'s primary-key section hardcode a specific
"safely out of the way" literal id (`999991`, `999992`, etc.) under
`allow_primary_key_write true`, on the assumption that the real sequence would never
naturally reach that high within a test run. That assumption broke the moment this fix
shipped: Postgres sequences are **not transactional** - a `reset_pk_sequence!` call
survives this test suite's own per-example transaction rollback (`use_transactional_fixtures`),
even though the row it was resyncing for gets rolled back same as always. So one example
bumping the sequence to `999991` left it there permanently for every example that ran
after it, and a later example's own hardcoded `999992` collided with an auto-assigned id
the sequence produced from that leftover position - reproduced directly:
`PG::UniqueViolation ... Key (id)=(999992) already exists`, order-dependent, only once
this fix existed to cause the bump in the first place. Fixed by resetting the sequence
back to its `MINVALUE` in a `before` hook that runs before every example in
`base_spec.rb`, while the table is still empty at that point (the same
`reset_pk_sequence!` this feature itself uses) - re-verified clean across 3 separate
`--order random` runs after the fix, not just the one seed that happened to fail first.

### Follow-up: a resync failure still leaves the sequence desynced - decided to accept this, not fix it

A first round of external review flagged that `reset_pk_sequence!` running
after the transaction, with nothing catching a failure from it, made `import!` raise for
a run whose rows had already committed - reporting an already-durable import as failed,
which invites an unsafe retry against data that's already there. Fixed narrowly at the
time: wrapped the call in `begin/rescue StandardError`, logging a `level: 'warning'`
entry instead of raising, so `import!` only ever raises for a genuine, not-written
failure.

**A second round of review correctly pointed out that this fix addressed the *reporting*
problem only, not the underlying one it sits on top of**: rescuing the failure doesn't
make the sequence resync succeed, retry, or become any less desynced - it just makes
`import!` report success (correctly - the rows *are* durable) while the actual hazard
this whole feature exists to prevent (a later, unrelated `Model.create!` colliding with
an id this run wrote manually) stays exactly as live as it was before this feature ever
existed, now with only a warning log line as the signal, easy for a caller that doesn't
inspect `#logs` to never notice at all.

**The structurally correct fix, considered and discussed, but deliberately not taken**:
move `reset_pk_sequence!` to be the last statement *inside* the run's own
transaction, instead of after it, and drop the rescue entirely. This would make success
and failure both atomic with the writes themselves - a resync success is guaranteed
consistent with the rows that determined it, and a resync failure rolls the whole
transaction back, restoring the simple invariant "`import!` raises means nothing was
written, safe to retry" without needing a rescue to preserve it. It doesn't fully close
the separate, harder concurrent-writer race in `reset_pk_sequence!`'s own two unguarded
statements (`MAX(id)` then `setval`) - that's a Rails-internal limitation, not something
foldable into a transaction - but it would fully close the "committed but silently
desynced forever" gap.

**Not taken, on explicit instruction, in favor of keeping the resync out of the main
transaction entirely** - the concern being that folding a best-effort maintenance step
into the same transaction as the actual, wanted data means that step's own reliability
now gets a vote over whether real, legitimate rows get to exist at all: a resync failure
(a transient connection blip, lock contention - not expected in ordinary operation, but
not impossible) would roll back rows the caller actually wanted written, for a reason
that has nothing to do with those rows being wrong. The rescue-and-log approach stays as
the shipped behavior: the import's own success is reported accurately (the rows are
genuinely durable), the resync failure is visible via `#logs`, and the residual risk (the
sequence itself staying desynced until some other run's own resync happens to succeed)
is accepted rather than engineered around further.

**A retry for the resync step itself was raised as a possible middle ground, not
pursued.** Worth revisiting if this risk ever becomes a real, observed problem rather
than a theoretical one - not implemented here since the trigger (a resync failure) is
itself rare enough that the added complexity wasn't judged worth it yet.

## `skip_file_validation` - added for the "one file, several target-model importers" pattern

Raised directly, discussing splitting one 9-column source file across 3 target tables (3
separate importer subclasses, a wrapping service calling `.import!` on each in order,
inside one shared transaction): the 2nd and 3rd importer each redundantly re-verify the
identical file - `Importer::Parsers::Csv#validate_file!` (a full byte-by-byte scan for `.csv`/`.tsv`) or the ZIP
signature check (`.xlsx`) - even though the first importer already proved the file is
valid. Header verification (`verify_headers!`) can't be skipped the same way, since each
importer's own `required_headers` can differ.

Added `skip_file_validation` (default `false`, `Importer::Concerns::Config`) - guards
`base.rb#import!`'s `parser.validate_file!` line
only; `verify_headers!` always still runs regardless, unconditionally.

**Verified directly that this delivers a real saving for `.csv`/`.tsv`, but essentially
none for `.xlsx` - an asymmetry worth calling out explicitly, not left implicit.**
`Parsers::Csv#validate_file!` streams the entire file's bytes before any row is read, genuinely separate
work from the (still-required, and much cheaper - only the first buffered chunk)
each parser's own `verify_headers!`. But for `.xlsx`, `Parsers::ExcelX#validate_file!`
is already the cheapest possible check (`File.binread(file_path, 4)`, no `Roo` involvement
at all) - confirmed by reading `parsers/excel_x.rb` directly: the actually expensive
part, `Roo::Spreadsheet.open` (verified elsewhere in this file to unzip the whole archive
to a tmpdir), is triggered by `Parsers::ExcelX#verify_headers!` itself (via `excel_workbook`), which
this setting can't skip. So `skip_file_validation` has no meaningful effect on a
second/third `.xlsx` import's actual cost - the redundant work for Excel lives entirely in
the part that must stay.

**Also verified directly, before finalizing the doc wording, that this doesn't make an
invalid file silently succeed - it only defers the failure to a worse one.** Initial
regression spec assumed a `.csv` with bad UTF-8 bytes would import cleanly with
`skip_file_validation true`; it didn't - Ruby's own `CSV.foreach` (used by
`each_csv_row` regardless of this setting) still raises `CSV::InvalidEncodingError` once
its own parsing actually reaches the bad bytes, just later (after any good rows before
it) and as a raw `CSV::InvalidEncodingError`, not this class's own clearer
`Importer::Base::ImportError`. The `.xlsx` case is the same shape: skipping the
ZIP-signature check on a genuinely non-ZIP file doesn't let it through either - `Roo`
still raises once it tries to open the file, just a raw rubyzip error instead of this
class's own "not a valid .xlsx file" message. Both regression specs assert the correct
thing (some other, non-`ImportError` exception still gets raised), not "no error at
all," which the first draft of the `.csv` spec incorrectly assumed until it failed and
corrected the record.

**Update: the claim above that ".xlsx's real cost can't be skipped" was true when
written, but is no longer true - see "Excel reading is no longer memory-bounded by
`roo`'s own eager extraction" below, which replaces the mechanism this section
described as unavoidable.**

## Excel reading is no longer memory-bounded by `roo`'s own eager extraction

Raised directly: memory is the priority for this class's Excel support, specifically
for large files - "our CSV process is streaming, I believe, and I expect `roo` read
Excel is streaming too, but someone read the code and say no, why not?"

Confirmed, then fixed. `.row(n)`/`.last_row` (what `Parsers::ExcelX#verify_headers!`/
`each_excel_row_number_and_values` used, previously) are backed by `Roo::Excelx::Sheet#cells`, which
eagerly extracts *every* cell on the sheet into an in-memory Hash the first time *any*
row is touched - header included, so the cost was paid even for a file whose data
columns are never all read. Verified directly, on a real 200,000-row `.xlsx` (built with
`caxlsx`): `.row(n)` in a loop peaked at **+1,410.8MB** RSS. `roo` does have a genuinely
streaming API, `each_row_streaming` (backed by `Nokogiri::XML::Reader`, a real
forward-only reader, not a full-document parse) - but it isn't a drop-in replacement,
for three separate reasons, each confirmed by reproducing the gap directly before
deciding how to fix it:

1. **Trailing padding.** `pad_cells: true` (an `each_row_streaming` option) fills a gap
   *between* cells that exist, but never after the last one - a row missing its final
   cell entirely (`["first", "middle"]`, 2 elements) doesn't get padded to match the
   header's own column count (3), unlike `.row(n)` (`["first", "middle", nil]`).
   **Not actually a problem in practice**: `excel_row_hash`'s own `headers.each_with_index`
   loop reads `row_values[index]`, and Ruby's `Array#[]` already returns `nil` past the
   end of a shorter array - identical behavior to explicit padding, with no extra code
   needed, verified directly.
2. **Row-number gaps.** A `<row>` element can be missing *entirely* from the XML (a
   genuinely blank row some writers omit rather than write as `<row r="N"></row>`) -
   verified directly that `each_row_streaming` (even the lower-level `SheetDoc` version,
   which does still expose each row's own `r` attribute) simply never yields anything
   for such a row, silently. Left alone, a naive "count how many times my block ran"
   row-number tracker would misattribute every row after the gap to the wrong number -
   exactly the "line number mismatch in logs" concern that was raised directly.
   Fixed by comparing each real yield's own row number (`r`, or `next_expected_row` when
   absent - the same "absent `r` means one more than the previous row" rule already
   relied on for merge detection/rich-text) against what was expected, and synthesizing
   `(row_number, [])` entries for any gap found. An empty values Array flows through the
   exact same `drop_blank_rows` handling any other blank row already gets - no special
   case needed once the row number itself is correct.
3. **Two genuine `roo`-internal gaps, not just missing conveniences - found by testing
   this class's own existing "cell/row `r` is optional" and "namespace prefix" regression
   fixtures against the new code, not assumed to just work because the old code's
   equivalent fixtures passed.** `roo`'s own `SheetDoc#each_cell` calls
   `Roo::Utils.extract_coordinate(cell_xml["r"])` unconditionally when no coordinate is
   pre-supplied - for a `<c>` missing its own `r` (legal per `CT_Cell`, and already known
   to matter: this project's own rich-text extractor has its own independent fix for
   exactly this), this raises `NoMethodError` deep inside `extract_coordinate` (`nil` has
   no `#each_byte`), reproduced directly before fixing anything. Separately, `roo`'s own
   `Roo::Utils.each_element(path, 'row')` (what `each_row_streaming` is built on) matches
   elements by exact name (`'row'`) - for a namespace-*prefixed* sheet (`<x:row>`/`<x:c>`
   under an `xmlns:x` declaration, legal if unusual XML this project's own existing specs
   already cover for the SAX-based merge/rich-text handlers), it yields **zero rows**,
   silently - confirmed directly, not inferred.

**Fixed by no longer going through `roo`'s own row/cell *discovery* at all - built
directly against `excel_sheet_xml_path` via `Nokogiri::XML::Reader` (the exact primitive
`roo`'s own streaming is built on), matching an element by its *local* name
(`node.local_name == 'row'`) rather than an exact one, and calling
`remove_namespaces!` on each row's own small reparsed fragment (never the whole
document - this stays exactly as memory-bounded as everything else) before reading it
further.** This normalizes away any prefix for both this class's own `row_element['r']`
reads and `roo`'s own internal `<is>`/`<f>`/`<v>` element matching inside `cell_from_xml`
(which has the identical non-namespace-aware gap `each_element` does, confirmed by
reading its source - not assumed to be fine just because the outer discovery was fixed).
For a cell missing its own `r`, a `Roo::Excelx::Coordinate` is built directly from this
class's own column tracking and passed in, rather than ever calling
`extract_coordinate` at all - `cell_from_xml`'s own `coordinate ||= extract_coordinate(...)`
skips that call entirely once a non-nil coordinate is already supplied. Row/cell
*value resolution* (native Integer/Float/Date/Boolean, shared-string lookup, style-based
number formats) still goes through `roo`'s own `cell_from_xml`, unchanged and reused
directly - reimplementing that maturity was never the point, only the row/cell
*discovery* wrapped around it needed replacing. Re-verified directly, same values, same
classes, as `.row(n)` for every native type this class supports.

**A real bug introduced while building this, caught by the full regression suite, not
found in isolation first.** `cell_from_xml(cell_xml, hyperlink, coordinate, empty_cell)`'s
second argument is a specific cell's own hyperlink value (`nil` for "none"), not a Hash -
the first version of this passed `{}` (this class never reads hyperlinks at all, so a
constant empty placeholder seemed harmless). It wasn't: `Roo::Excelx::Cell::Date`/
`DateTime#initialize` does `link ? Roo::Link.new(link, value) : create_date(...)`, and
`{}` is truthy in Ruby - so *every* cell, not just dates, took the "this has a hyperlink"
branch and returned its own raw, uncoerced content string instead of a properly typed
value. Caught immediately by 28 of the 30 regression specs the first full run after this
change (native `Integer`/`Float`/`Date`/`Boolean` values all silently became strings) -
fixed by passing `nil` instead, re-verified clean.

**Re-verified end-to-end, through the real `Importer::Base#import!` pipeline, not just
the isolated read.** A 200,000-row `.xlsx`, `raw_insert_all` mode, all 4 native column
types: 200,000 rows correctly inserted, RSS `309.6MB -> 217.0MB` (no growth at all,
comfortably within ordinary GC variance) - compare to the `+1,410.8MB` the old `.row(n)`-based
code produced reading the identical file. Full importer spec suite (283 examples) passes,
re-run clean across multiple `--order random` seeds, rubocop clean.

Three new regression specs added directly for behavior this rewrite is responsible for
that no existing spec exercised: a row entirely missing from the XML (treated as blank,
not miscounted), a genuinely missing trailing cell (comes through as `nil`, not shifted
onto a neighboring column), and the sheet-doesn't-start-at-column-A case for *ordinary*
(non-rich-text) column mapping specifically - the existing regression for that shape only
ever covered `rich_text_target_columns`, not `excel_row_hash` itself.

### Follow-up: re-verified memory at scale, one phase at a time, not just end-to-end

Asked directly to re-check every phase separately ("read header row", "check it's a ZIP",
"row processing", "rich-text fetching") rather than trust the single end-to-end 200,000-row
number above - each phase measured on its own, through the real class, not an isolated
script:

- **ZIP-signature check**: `0.02-0.05ms`, `0.0MB` RSS delta, identical at 5,000 rows and
  500,000 rows - confirmed genuinely `O(1)`, exactly as its own implementation
  (`File.binread(file_path, 4)`) implies.
- **Header-row capture**: memory stayed flat at both scales, but *time* did not -
  `9.55ms` at 5,000 rows vs. `1125.89ms` at 500,000 rows. Traced before assuming this was
  a regression: isolated `Roo::Spreadsheet.open` alone (no row reading at all) accounts
  for effectively all of it - `24.3ms` vs. `914.5ms` at the same two scales. This is the
  one-time archive extraction this class has always paid (verified, and already
  documented, since before this session's rewrite: `roo` extracts the whole `.xlsx` zip
  to a tmpdir up front, unconditionally, the moment the file is opened at all) - a real
  disk-I/O *time* cost that scales with archive size, not a memory cost, and not
  something this rewrite introduced or could remove while still reusing `roo` for
  shared-strings/styles/cell-type resolution. `sheet_for(...).instance_variable_get(:@sheet)`
  itself (the actual "get ready to read this sheet's rows" step) measured `0.0ms` at
  both scales, separately.
- **Row processing**: two separate, isolated (fresh-process) runs to avoid the same
  cross-run GC-reuse contamination noted earlier in this file - `raw_insert_all`, all 4
  native column types, through the real `Importer::Base#import!`:
  ```
  250,000 rows: 42.5s,  RSS 364.1MB -> 241.6MB (delta -122.5MB)
  750,000 rows: 187.1s, RSS 858.8MB -> 444.9MB (delta -413.9MB)
  ```
  3x the rows, and the RSS delta is still negative (no growth) at both scales - not
  proportional to row count in either direction. Time scales close to linearly with row
  count (expected and unavoidable - every row has to be cast and written somehow), which
  is a throughput property, not a memory one.
- **Rich-text fetching**: the scale most worth checking specifically, since this
  rewrite changed how the *main* row reader tracks row numbers, and rich-text extraction
  is a *second, entirely independent* SAX reader over the same sheet XML that has to stay
  aligned with it - a misalignment here wouldn't necessarily crash, it could silently
  attribute one row's rich-text data to a different row. Built a 250,000-row file with
  ordinary plain-text `Notes` cells throughout, and real two-run rich-text cells
  deliberately scattered at rows 1, 50,000, 125,000, 200,000, and 249,999 (first row,
  last row, and three points in between). `raw_insert_all`, `rich_text_headers`
  declared, real `cast_notes` converting bold runs to `<b>`:
  ```
  imported=250,000, time=38.8s, RSS 277.1MB -> 223.2MB (delta -53.9MB)
  ```
  Every one of the 5 rich-text rows resolved its exact expected value
  (`"plain-N-<b>bold-N</b>"`), and every plain row checked immediately before/after each
  rich-text row (including the very first and very last rows of the file) resolved its
  own correct plain text, not a neighboring row's - confirming the row-number tracking
  this rewrite introduced for the main reader stays correctly aligned with the
  independent rich-text SAX reader's own tracking, at both ends of a large file, not
  just in the small hand-built fixtures the regression suite uses.

No file-size-dependent memory growth found in row/cell *structure* reading, across any
of the four phases. Two caveats worth remembering going forward, neither introduced by
this rewrite and neither about row/cell structure specifically:

1. Opening a `.xlsx` file at all has a real, disk-bound *time* cost proportional to
   archive size - unrelated to memory, already true before this rewrite, and not
   avoidable without dropping `roo`'s own value-typing entirely (see the "gem choice"
   reasoning at the top of this file for why that trade isn't taken).
2. **Shared-string *value resolution* (a separate concern from row/cell structure,
   still entirely `roo`'s own responsibility) is not memory-bounded at all** - see
   immediately below.

## `roo`'s own shared-string table is not memory-bounded - a real, deliberately deferred gap

Checked directly, not assumed, after the row/cell structure rewrite above: does a real
`.xlsx` file's *text* content - not just its row/cell shape - also stay memory-bounded at
scale? Every fixture used to verify the rewrite above (and every fixture `caxlsx`, this
project's own test generator, can produce at all) uses **inline strings**
(`t="inlineStr"`), never OOXML's other, and more common in real Excel/Google
Sheets/LibreOffice-authored files, text representation: a **shared-string table**
(`sharedStrings.xml`, referenced by numeric index, `t="s"`) - a dedup mechanism Excel
uses by default specifically because most real spreadsheets repeat the same values many
times. None of this session's scale testing had actually exercised that path at all.

Checked `roo`'s own `Roo::Excelx::SharedStrings#to_a` (`shared_strings.rb`) directly:
`@array ||= extract_shared_strings`, and `extract_shared_strings` does a **full
`Nokogiri::XML` parse** of the entire `sharedStrings.xml` (`document.xpath('/sst/si')`,
mapped into a Ruby Array) the first time *any* shared-string cell is read - the exact
same "eager, whole-thing-into-memory" shape `.row(n)` had for row/cell structure, just
for text content instead, and this class's own row/cell rewrite never touches it at all
- every real cell value still flows through `cell_from_xml`, which reads shared strings
via `shared_strings[index]`.

Verified directly, since `caxlsx` can't produce this shape at all (hand-built the sheet
XML and a matching `sharedStrings.xml` directly, the same technique already established
elsewhere in this file for shapes `caxlsx` can't generate): a 300,000-row file where
every row references its own genuinely unique shared string (a deliberately adversarial
case - most real files repeat far more) -

```
imported=300,000, time=12.5s, RSS 253.2MB -> 439.4MB (delta +186.2MB)
```

- real growth, roughly proportional to the number of *unique* strings in the workbook,
not to row count directly (a file with heavy repetition wouldn't grow nearly this much,
since `roo`'s own table only ever holds each *unique* string once).

**Deliberately not fixed yet, after weighing the options directly, not because a fix
isn't possible:**

Row data is naturally sequential (row 5 always follows row 4 in document order), which
is exactly what made the row/cell rewrite above a clean, one-directional win with no
real downside. Shared-string access is index-based, not sequential - a cell early in the
sheet can reference the *last* declared string, and vice versa, so there's no
"stream forward, keep only what the next row needs" trick available the same way. Two
real options were considered:

1. **Replace `roo`'s full-DOM parse with this class's own SAX-based one, still holding
   every unique string in memory.** Doesn't fix "grows with unique-string count," but
   this codebase already measured a ~30x memory difference between a DOM and SAX parse
   of comparable content (see the `<mergeCells>` investigation earlier in this file:
   1.17GB vs 37.5MB on the same 52MB sheet entry) - the same multiplier here would very
   plausibly turn the 186.2MB delta above into single digits. No speed cost either way -
   SAX skips building DOM node objects entirely, if anything slightly faster.
2. **True random access**: a byte-offset index built during one pass (cheap - just
   numbers, not string content), then seek-and-parse each string on demand, only ever
   holding what's actually been referenced. Gets closer to genuinely flat memory, but
   real files repeat shared strings by design - without a cache, every *repeated*
   reference to an already-seen index would re-seek and re-parse from disk, a genuine
   slowdown for the common case (a handful of distinct strings referenced across many
   rows), not a free improvement. A cache would avoid that cost but brings memory growth
   back, proportional to how many *distinct* indices actually get referenced (better
   than every *declared* one, per option 1's own remaining gap, but still not flat for a
   file whose content genuinely is mostly-unique).

Neither has been built. Raised directly, confirmed as a real, reproducible gap
(not a hypothetical), and deliberately left as a documented limitation rather than
implemented speculatively - option 1 is the one worth reaching for first if a real file
ever needs it (large, low-risk, no speed cost), option 2 only if that alone turns out
insufficient.

## 2.0.0 - composition (parser/loader/row-transformer) instead of one mixin-heavy base

Raised in PR review: `Importer::Base` `include`d ~13 modules unconditionally - both CSV
and Excel parsing, all four write modes, the primary-key and unique_by guards, hooks,
logging, row-isolation retry - regardless of which any given subclass actually used. A
`:raw_insert_all` importer of a `.csv` still carried every line of the Excel rich-text SAX
machinery and all three other modes' write paths on its own singleton.

**The counter-argument was taken seriously first, not skipped.** The mixin shape is
genuinely idiomatic Rails - `ActiveRecord::Base` is built exactly that way - and "too many
concerns" is not on its own a defect. Two things decided it:

1. **Testing anything in isolation was impossible.** Every test of CSV parsing, of cast
   behavior, of a single mode's write path, had to construct a full `Importer::Base`
   subclass with a real `target_model`, a real file, and a full valid config, because that
   was the only object that had the method under test. There was no smaller unit.
2. **One namespace, ~13 sources.** Every module's private helpers landed on the same
   object. This had already caused one real bug (the `cast_<attribute>`/`parse_*`
   collision documented earlier in this file) - a class of bug that simply cannot occur
   once each concern is its own object with its own method table.

Against that, the cost is real and worth stating: **two more files, and a small number of
explicit backreferences where there used to be none.** This is not a pure win.

### The object graph is a star, not a mesh

Only `Importer::Base` holds references to the collaborators, and **the collaborators never
reference each other** - no parser knows a loader exists, no loader knows a parser does.
What each one owns is its own job; none of them owns any part of `Base`'s orchestration.

Four real edges back to `Base` remain, and are worth naming rather than glossing:

1. **The error class.** Every collaborator that can raise a user-facing import failure
   raises `Importer::Base::ImportError`, fully qualified - both parsers, the row
   transformer, and four of the loader files (seven of the sixteen collaborator files in
   all). A genuine shared dependency on `Base`, kept there deliberately: it is the
   exception a *caller* rescues, so moving it would change the frozen public API for no
   internal gain.
2. **`host:`** - the live `Importer::Base` instance, held by the loaders and
   `RowTransformer`. Narrowed by convention (only `cast_<attribute>` and `on_row_skip` are
   ever dispatched through it) rather than by type. See below.
3. **`importer_class:`** - the concrete subclass, passed to both parsers'
   `validate_config!`, to the loaders, and to `RowTransformer` (and onward from
   `Loaders::Base` to `UniqueByResolver`). The weakest edge of the four: it exists only to
   prefix error messages (`"#{@importer_class}: ..."`), so it is duck-typed on `to_s` -
   the isolation specs pass the plain String `'StandaloneSpec'`.
4. **`target_model`** - loaders and `UniqueByResolver` need a real model by definition: a
   loader writes to one, the resolver reads its indexes. Only the parsers and the logger
   are genuinely model-free.

So: a parser or the logger can be constructed with no `target_model` and no importer
subclass at all; a loader needs a model, but nothing more of `Base` than a `host` double
and a String to name it in errors.

### Why `host:` and `logger:` exist at all

Loaders and `RowTransformer` take a narrow `host:` backreference plus a `logger:`. This is
deliberate, and it is edge 2 above - the one place the star points back at the instance:

- `cast_<attribute>` and `on_row_skip` are **frozen subclass-facing API** - they are
  defined as plain instance methods directly on the user's own subclass. Dispatching to
  them means calling back into that object. `host` is that object, narrowed to the two
  things actually dispatched.
- `logger:` is passed rather than reached for, so a loader logging a skipped row doesn't
  need to know `Importer::Base` exists.

The alternative - having `Base` pre-resolve every cast into a callable and hand those
down - was considered and rejected: it would move the frozen `cast_<attribute>` contract
into a place a subclass author never looks, for no testability gain (a `host` double is
already trivial to build).

### Where each old concern went

`casting.rb` -> `row_transformer.rb`. `logging.rb` -> `logger.rb`. `primary_key_guard.rb`
and `unique_by_guard.rb` -> `loaders/base.rb`. `row_isolation.rb` ->
`loaders/row_isolatable.rb`, now included only by the two raw modes that can use it.
`csv_parsing.rb` -> `parsers/csv.rb`. `excel_parsing.rb` -> `parsers/excel_x.rb`.
`excel_rich_text.rb` -> `parsers/excel_x/rich_text.rb`. `modes/*` -> `loaders/*`.
`validation.rb` was split rather than moved - see below. `config.rb` and `hooks.rb` did
not move; neither ever straddled anything.

### `validation.rb`'s ordering dependency became structural

`assert_unique_by_valid!` wrote three ivars that two later assertions read, and nothing
but a comment enforced that order. Constructing `Importer::Loaders::Base` now *is*
"resolve and validate `unique_by`": it either succeeds and the loader exists with a
populated, frozen `unique_by_config`, or it raises and no loader exists.
`assert_primary_key_write_protected!` runs after that line in `assert_configured!` and
reads `loader.unique_by_config` - a plain top-to-bottom local read.

**This did change which config error surfaces first** when a subclass has more than one.
`unique_by` resolution and the two `activerecord_import` guards now run later (inside the
loader's constructor); `on_failure`, `csv_delimiter`/`csv_encoding` and
`header_row`/`data_start_row` now run earlier. Each individual message is byte-identical,
and all of them still raise `ArgumentError` at config time before any row is read - but a
subclass with both a bad `unique_by` and a bad `on_failure` now reports the `on_failure`
one. Verified directly.

### `process_row` was deleted, not moved

It straddled the split: called from inside both parsers' streaming loops, but doing
business logic (`drop_blank_rows`, `exclude_row?`) and setting `@current_row`/
`@current_line_number`. Both `each_row` implementations are now unconditional - they yield
every row and decide nothing - and `import!`'s own loop took over its body verbatim,
preserving the ordering documented earlier in this file.

### Rich text stayed pull-based

`rich_text_header_value` is called from inside a subclass's own `cast_<attribute>`, but the
data is extracted by Excel-parser-side SAX machinery. It is a query method on the parser
rather than something bundled into what `each_row` yields - bundling would have forced a
rich-text-shaped parameter into `Parsers::Csv#each_row`, which never has any.
`Parsers::Csv` does not implement the method at all; `Base` returns `nil` for a non-`.xlsx`
import before ever delegating.

### What "testable in isolation" was actually checked against

Not asserted, checked: `logger_spec.rb`, `loaders_spec.rb`, `parsers_spec.rb`,
`row_transformer_spec.rb` and `loaders/unique_by_resolver_spec.rb` each construct their
subject directly, with **no `Importer::Base` subclass anywhere** - no `target_model`
macro, no `mode`, no `required_headers`, none of the config DSL. `logger_spec` and
`parsers_spec` additionally need no `target_model` at all; the loader and resolver specs
pass a real model, because a loader writes to one and the resolver reads its indexes (see
edge 3 above) - that is inherent to what they do, not leftover coupling.

That is the concrete form of the benefit this refactor was for; the ~300 pre-existing
end-to-end examples are what proves the behavior didn't move underneath it.
