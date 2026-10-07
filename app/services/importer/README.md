# Importer

`Importer::Base` bulk-seeds a single ActiveRecord model from a CSV, TSV, Excel
(`.xlsx`), or zipped single-CSV (`.zip`) file. Subclass it, declare `target_model`, `mode`, and `required_headers`, and
call `.new(file_path:).import!` - `file_path`'s own extension picks the format, nothing
else to declare.

Example subclasses live in `app/services/importers/` (plural), a separate,
application-specific directory - kept out of this one so the shared engine here
(`base.rb`, `parsers/`, `loaders/`, `row_transformer.rb`) stays agnostic to any one
application. See
[`Importers::PostInsertImporter`](../importers/post_insert_importer.rb),
[`Importers::PostUpsertImporter`](../importers/post_upsert_importer.rb), and
[`Importers::PostActiverecordImportImporter`](../importers/post_activerecord_import_importer.rb)
for a minimal working example of each of those 3 modes.
[`Importers::PostActiveRecordImporter`](../importers/post_active_record_importer.rb) is
the 4th (`:activerecord`), and also doubles as the full reference example: every
`cast_<attribute>`/hook/accessor this class supports (`raw_header_value`,
`rich_text_header_value`, `file_format`, `exclude_row?`, `on_row_skip`, `before_batch`,
`after_batch`), plus the Excel-only config macros (`sheet_name`, `header_row`,
`data_start_row`), is demonstrated there, with a comment on every line - reading that
one file end to end should cover everything below without needing this README at all.

For the full, point-form list of every rule this class follows (delimiters, encoding,
header handling, Excel-specific config, etc.), see [REQUIREMENTS.md](REQUIREMENTS.md).
For the reasoning and exact test results behind those rules - what was tried, what
broke, what the numbers were - see [FINDINGS.md](FINDINGS.md). This file stays a usage
guide and a TODO list; the "why" lives in those two instead.

## Usage

Given an already-defined subclass (see the examples linked above), calling it is the
same regardless of mode - keep a reference to the instance, since `#logs` is read off
of it, not off whatever `import!` returns. `import!` raises on any failure by default
(`on_failure :rollback`), so wrap the call in `begin`/`rescue` if you want to inspect
`#logs` afterward instead of letting the exception propagate:

```ruby
importer = Importers::PostInsertImporter.new(file_path: "tmp/posts.csv")

begin
  importer.import!
rescue Importer::Base::ImportError
  # handled below via importer.logs
end

importer.logs
# => [
#      { level: "error", row: 4, column: "quantity", message: "invalid integer: \"abc\"" }
#    ]
```

`#logs` is a plain, JSON-safe Array of Hashes - safe to persist or render as-is, no
custom objects or embedded exceptions. Note there's no summary entry above: it's only
appended once `import!`'s own transaction block returns *without* raising, so a
`:rollback` failure leaves `#logs` with only the error entry that caused it. A failure
that isn't row-level (bad file encoding, a missing required header) raises before any
row is processed too, so `#logs` stays empty in that case. For a mode/config that
supports `on_failure :skip` (`:activerecord`/`:activerecord_import`), a row-level
failure doesn't raise instead - `import!` returns normally, and `#logs` then also gets a
summary entry (`{ level: "info", message: "import completed", processed:, written:,
skipped:, excluded: }`) reflecting what was actually written.

`written` is rows *written*, not rows created: for the insert-or-update modes
(`raw_upsert_all`, and `activerecord`/`activerecord_import` with `unique_by` declared) it
counts inserts and updates together, because a bulk upsert doesn't report which rows
conflicted. If you need those apart, count them yourself in `after_batch` - each item
carries `:primary_key_value` once written.

## Modes

Every subclass must declare which mode it uses via `mode`, even while not all five are
implemented yet, so adding a mode later is purely additive rather than needing an
implicit default existing subclasses would silently inherit.

### `raw_insert_all` (implemented)

Bulk SQL INSERT via Rails' `insert_all!`.

- ❌ Runs model validations
- ❌ Runs model callbacks
- ❌ Can write to a virtual/writer-method attribute (real columns only - no model is instantiated)
- ❌ Insert-or-update on conflict (insert only; `insert_all!` raises on a duplicate-key conflict instead of silently skipping it, which is deliberate - see `raw_upsert_all`)
- ⚠️ Returns the written primary key (`:primary_key_value` in `after_batch`) - only when the row's own attrs already had it (`allow_primary_key_write true`); never for a "blind" insert with neither, since this mode has no `unique_by` to fall back on - see REQUIREMENTS.md's Primary key section
- ✅ Fail and rollback (the current, only behavior - one batch is one SQL statement)
- ❌ Fail and skip (considered and rejected - see FINDINGS.md)
- ✅ Works on any database Rails supports

### `raw_upsert_all` (implemented)

Same mechanism as `raw_insert_all`, via Rails' `upsert_all`. Subclass must declare
`unique_by` - a column, an array of columns for a composite key, or an index name, all
three being exactly what `upsert_all` itself accepts - naming a real unique index,
checked up front, before any row is processed, not left to fail on first write.

- ❌ Runs model validations
- ❌ Runs model callbacks
- ❌ Can write to a virtual/writer-method attribute (real columns only)
- ✅ Insert-or-update against a declared conflict key
- ✅ Returns the written primary key (`:primary_key_value` in `after_batch`) - resolved via `unique_by` (always declared for this mode) or a supplied PK - see REQUIREMENTS.md's Primary key section
- ✅ Fail and rollback (same as `raw_insert_all`)
- ❌ Fail and skip (same cost as `raw_insert_all`'s - see its row above)
- ❌ Works on any database Rails supports (Postgres/SQLite only - MySQL/MariaDB don't
  support `unique_by`; see FINDINGS.md)

### `raw_copy` (not yet implemented)

Postgres `COPY`, staged through a temp table. The fastest of the five modes.

- ❌ Runs model validations
- ❌ Runs model callbacks
- ❌ Can write to a virtual/writer-method attribute (real columns only)
- ❌ Insert-or-update on conflict (`COPY` has no `ON CONFLICT` equivalent; an upsert variant would still need the staging-table-then-`INSERT ... ON CONFLICT` detour)
- ❓ Returns the written primary key (`:primary_key_value` in `after_batch`) - not yet decided, since this mode itself isn't implemented yet
- ✅ Fail and rollback (one `COPY` statement is atomic)
- ✅ Fail and skip - natively, via Postgres 17+'s `COPY ... WITH (ON_ERROR ignore)`
- ❌ Works on any database Rails supports (Postgres only)

### `activerecord_import` (implemented)

The `activerecord-import` gem, via `Model.import`. One bulk INSERT per batch, with a real
model instantiated per row, so validations run - unlike the raw_* modes. Real columns
only, no virtual/writer-method attribute support (see FINDINGS.md for why). `unique_by`
is optional, same convention as `:activerecord`; unlike other modes, it must resolve to
real column(s), not an index name, since that's what the gem's own conflict target
accepts. `required_headers` must map at least one column besides `unique_by`'s own, or
there's nothing left to refresh on conflict - raises at config time.

Supports `on_failure :skip`, but only for a row that fails model validation - a
DB-level failure not caught by validation always rolls back the whole run instead. See
FINDINGS.md for why.

- ✅ Runs model validations (a model is instantiated per row)
- ❌ Runs model callbacks (never fire on a bulk INSERT)
- ❌ Can write to a virtual/writer-method attribute (see FINDINGS.md)
- ⚠️ Insert-or-update against a declared conflict key (`unique_by`, optional - see above) - not on MySQL/MariaDB, a gem limitation (see FINDINGS.md)
- ⚠️ Returns the written primary key (`:primary_key_value` in `after_batch`) - only when the row's own attrs already had it, or `unique_by` is declared; never for a "blind" insert with neither - see REQUIREMENTS.md's Primary key section
- ✅ Fail and rollback (`on_failure :rollback`, the default)
- ✅ Fail and skip, for a validation failure only (`on_failure :skip` - see above)
- ⚠️ Works on any database Rails supports for a plain insert; `unique_by` (insert-or-update) raises at config time on MySQL/MariaDB instead - see FINDINGS.md

### `activerecord` (implemented)

Plain `create!`/`save!` per row - the slowest of the four, one statement per row.
`unique_by` is optional: if declared, `find_or_initialize_by` looks up the existing
record first; if not, every row is always a new record. Supports `on_failure :skip`,
but only for a failure inside `save!` itself - a bad cast, or any other exception (a
buggy callback, `throw :abort`), always rolls back the entire run instead. See
FINDINGS.md for why.

- ✅ Runs model validations
- ✅ Runs model callbacks (the only mode where callbacks genuinely fire)
- ✅ Can write to a virtual/writer-method attribute
- ✅ Insert-or-update, via `unique_by` + `find_or_initialize_by` (see above)
- ✅ Returns the written primary key (`:primary_key_value` in `after_batch`) - resolved directly from the row's own `save!`, no `unique_by` needed
- ✅ Fail and rollback (`on_failure :rollback`, the default)
- ✅ Fail and skip, for a validation failure or a DB-level error raised by `save!` itself (not for a bad cast or any other exception - see above)
- ✅ Works on any database Rails supports

## Design in brief

- **File format is auto-detected from `file_path`'s extension, never declared
  separately.** A subclass doesn't say which parser is in play - the extension alone
  decides, internally, the same way `.csv` vs `.tsv` already picks a delimiter. A
  subclass can read this decision back via `file_format` (`:csv`/`:tsv`/`:xlsx`) from
  any `cast_<attribute>` or hook, for whenever behavior needs to differ by source
  format.
- **A `.zip` is read as the one CSV/TSV inside it.** `Importer::Parsers::ZippedCsv`
  extracts that entry to a tempfile (removed when `import!` finishes, even on failure)
  and hands it to the CSV parser, so delimiter, encoding and line numbers behave exactly
  as for a plain `.csv`. The archive must hold exactly one real file, ending `.csv` or
  `.tsv` - macOS `__MACOSX/` entries are ignored; anything else raises `ImportError`,
  including a zipped `.xlsx`. An entry over 512 MB uncompressed is refused - raise or lower that with
  `max_uncompressed_bytes 100.megabytes` (any positive Integer; ActiveSupport's
  `kilobytes`/`megabytes`/`gigabytes` keep it readable). `file_format`
  returns the inner file's format (`:csv` or `:tsv`).
- **CSV or TSV, UTF-8 by default - or a declared `csv_encoding` for a source you don't
  control.** Encoding is checked as its own pass before any row is processed, so a bad
  file fails cheaply rather than partway through an import. `csv_encoding 'Windows-1252'`
  (or any encoding Ruby knows - `Encoding.name_list`) transcodes every row to UTF-8 on
  the way in; an unknown encoding name raises at config time, and a byte that doesn't fit
  the declared encoding raises during the pre-pass, naming the line. Deliberately not a
  generic passthrough of arbitrary CSV-parser options - only the encoding is exposed,
  to keep the surface small and safe. `.csv` uses comma by default (or semicolon via
  `csv_delimiter ';'`); `.tsv` always uses tab. See REQUIREMENTS.md for the full
  file-format rules.
- **`skip_file_validation` skips that whole-file check** (the UTF-8 pass, or `.xlsx`'s
  ZIP-signature check) - for when several importers share one `file_path` and an
  earlier one already paid for it. Never skips header verification. A real saving for
  `.csv`/`.tsv`; for `.xlsx` the ZIP-signature check was already the cheapest possible
  one, so this has little effect there either way. See REQUIREMENTS.md/FINDINGS.md.
- **Row/cell reading, CSV or Excel alike, is memory-bounded** - one row at a time,
  never the whole file loaded into memory at once, regardless of file size. For
  `.xlsx` specifically, this isn't something the underlying `roo` gem's default
  row-access API provides (`.row(n)` eagerly loads the whole sheet into memory the
  first time any row is touched) - and `roo` does have its own genuinely streaming
  API (`each_row_streaming`), but it isn't a safe drop-in: it doesn't pad a row
  missing its own trailing cell, it silently skips a row missing from the XML
  entirely rather than reporting the gap, and its own internals aren't hardened
  against two cases this class already has regression coverage for (a cell missing
  its own `r` attribute; a namespace-prefixed sheet). This class reads the raw sheet
  XML directly instead, handling all of that itself, and reuses `roo` only for
  per-cell value typing (native types, shared strings, number formats) - the part
  worth not reimplementing. See FINDINGS.md for the measured difference and each gap
  found. This covers row/cell *structure* only - see the TODO section below for a
  real, separate memory gap in `roo`'s own shared-string *value* resolution.
- **Header-order-agnostic column mapping.** `required_headers` maps header text to a
  model attribute; column position in the file doesn't matter, and stray whitespace
  around a header name doesn't count as a missing column.
- **An attribute with no source column at all is declared, not faked** -
  `derived_attributes :is_global`, with its value produced by that attribute's own
  `cast_is_global` (typically from other columns via `raw_value_for`). Written identically
  to a mapped attribute in every mode, and checked the same way at config time; its cast
  receives `nil`, since there's no column for it to come from, and that cast method is
  *required* to exist - the default caster given `nil` would silently write `NULL`. Before
  this existed, the only way to compute such an attribute was mapping it to an unrelated
  header purely as a carrier for its `cast_` method.
- **A column holding another record's natural key becomes a real foreign key** -
  `resolve_belongs_to :organization_id, by: :slug`. A source file refers to another record
  by whatever key it uses itself (a UID, a country code, an acronym), never by this
  database's ids, so this translation is needed by every importer that isn't a standalone
  lookup table. The associated model is read from `target_model`'s own `belongs_to`
  reflection for that foreign key (so `parent_agreement_id` finds `belongs_to
  :parent_agreement` without extra declaration); lookups are cached per distinct value for
  the whole run; a blank value resolves to `nil`, and a **present** value matching nothing
  **raises** rather than silently writing `NULL`.
- **A fully blank line is dropped, not written as an all-`NULL` row** by default -
  disable with `drop_blank_rows false`.
- **A subclass can exclude a row entirely, on its own business rule, before any cast or
  write is attempted - `exclude_row?(row)`.** `row` is every column in the file for that
  row (not just the ones in `required_headers`), keyed by stripped header text - so a
  metadata-only filter column never has to be mapped or writable on `target_model` just
  to be checked here. Counted separately (`@excluded_count`/`excluded:` in the summary
  log entry) from a row that failed once attempted (`on_failure :skip`).
- **A subclass can react to a row being skipped, or observe a batch write, as either
  happens** - `on_row_skip(line_number:, attrs:, message:)` (only reachable when
  `on_failure :skip` actually drops a row) and `before_batch(batch)`/
  `after_batch(batch)` (never called for an empty batch). Every batch item carries
  `:row` - the raw row Hash behind it, every column included, so a hook can act on a
  column `required_headers` deliberately doesn't map. By the time `after_batch`
  runs, a written item may also carry `:primary_key_value` - the real primary key that
  row became, resolved **by value, never by position** (see FINDINGS.md for why).
  Populated only when the row's own attrs already had the primary key, or `unique_by`
  is declared; never for a "blind" insert with neither, or for two rows sharing the
  same `unique_by` value in one batch. See REQUIREMENTS.md's Primary key section for
  the full per-mode rule. All three hooks are no-ops by default; a raise from any of
  them rolls back the whole run. `before_import`/`after_import` were considered and
  dropped - see FINDINGS.md.
- **Every value is strictly cast**, regardless of mode - Rails' own casting is silently
  lossy on invalid input, so this class never relies on it. A subclass overrides the
  default for one column with `cast_<attribute>`. This includes a `:decimal` column's own
  `scale`: a value with more fractional digits than the column allows raises, rather than
  silently rounding away the excess the way `ActiveRecord::Type::Decimal#cast` does on
  its own.
  - **CSV/TSV**: every value arrives as a plain String, cast according to the target
    column's own DB type. The default caster covers `:integer`, `:decimal`/`:float`,
    `:date`/`:datetime`, `:boolean`, and `:string`/`:text` (a no-op) - anything else
    (`:jsonb`, an array or enum column, etc.) raises unless a subclass defines
    `cast_<attribute>` for it. There's no silent passthrough for an unhandled type.
  - **Excel**: a cell's native type (`Integer`/`Float`/`Date`/`TrueClass`/`FalseClass`)
    is used directly when it already matches the target column's type - no re-parsing,
    no precision loss. Otherwise (a `String` cell, or a native type that's wrong for
    that column) it falls back to the exact same cast pipeline CSV uses above.
- **Fail-fast, all-or-nothing for the `raw_*` modes.** The whole run is one transaction;
  any failure rolls back everything written so far. `activerecord` and
  `activerecord_import` can instead run with `on_failure :skip` - each covers a
  different, narrower scope than "any way a row can fail"; see the Modes section above.
- **`#logs` is JSON-safe and populated even when the run fails**, so a caller (a Job, an
  `ImportRun` model) can persist or display what went wrong without parsing an exception
  message.
- **`unique_by` is one concept shared across modes, not a separate one per mode.**
  Required for `raw_upsert_all`; optional for `activerecord`/`activerecord_import`
  (insert-or-update if declared, always-insert if not).
- **`allow_primary_key_write` (default `false`) gates writing a caller-supplied primary
  key value, never mapping or looking it up.** Reading/matching by primary key is always
  allowed, in any mode with a lookup step (`raw_upsert_all`, `activerecord`,
  `activerecord_import` - `unique_by` must resolve to the primary key itself for this).
  `raw_insert_all` has no lookup step at all, so mapping the primary key there without
  this enabled raises at config time instead. Type-agnostic - works the same whether the
  primary key is an auto-incrementing integer or something else entirely, e.g. a
  client-generated UUID (needs its own `cast_id`, same as any other type the default
  caster doesn't cover - not a UUID-specific exception). See REQUIREMENTS.md's Primary
  key section for the full per-mode table and a worked UUID example, and FINDINGS.md for
  the reasoning and the empirical gotchas it took to get right.
- **Whenever `allow_primary_key_write` is `true`, the run's Postgres sequence gets
  resynced automatically, once, after the run succeeds.** Writing an explicit id never
  advances a `SERIAL`/`IDENTITY` column's own sequence - left alone, a later, unrelated
  plain `Model.create!` elsewhere in the app can collide with an id this class already
  wrote manually. No-op on a non-Postgres adapter, a primary key with no sequence (e.g. a
  UUID column), or an empty table. Deliberately kept out of the run's own transaction -
  see FINDINGS.md for the reproduction and the known, accepted risk this leaves in place
  when the resync itself fails.
- **Excel rich-text (per-run formatting, plus per-cell background color) fidelity is
  opt-in, per column.** Declare `rich_text_headers ['Some Header']` (header text, not
  attribute name), then call `rich_text_header_value('Some Header')` from inside any
  `cast_<attribute>` to get that row's formatting data back. Returns `nil` for a header
  not in this file, or for a non-`.xlsx` import - never a raise, so a `cast_<attribute>`
  shared across formats never needs its own format check first. Only runs for declared
  columns, so a subclass that never declares `rich_text_headers` pays nothing for the
  feature existing. See REQUIREMENTS.md's Rich text section for the full return shape
  and rules, and FINDINGS.md for the extraction design.

## TODO

- **`#logs` is bounded by `batch_size`, not file size - incidentally, not by design.**
  The run aborts entirely on the first failing batch, so at most `batch_size` entries
  are ever produced. This bound wouldn't hold for a mode that supports skip-and-continue
  across the whole file - revisit if that's ever built.
- **Rich-text extraction has only been exercised against synthetic fixtures, not a
  workbook actually saved by real Excel/Google Sheets/LibreOffice.** Both the
  inline-string and shared-string paths are covered, and two rounds of external review
  already caught real bugs synthetic fixtures missed (see FINDINGS.md) - a real-file
  smoke test is still worth doing before leaning on this in production.
- **Per-property style inheritance for a cell with its own rich-text run(s) isn't
  implemented** - only whole-cell fallback for a cell with no run at all. See
  FINDINGS.md for why this is scoped deliberately.
- **A gradient fill's own color stops, angle, or path aren't extracted** - only that a
  cell has one at all (`{ pattern_type: :gradient }`). Non-solid pattern fills
  (stripes/hatching) *are* fully supported (`pattern_type`/`fg_color`/`bg_color`).
- **`.xlsx` shared-string *values* aren't memory-bounded, unlike row/cell structure** -
  `roo`'s own `SharedStrings` class does one full, non-streaming DOM parse of the
  entire `sharedStrings.xml` the first time any shared-string cell is read, holding
  every unique string in memory for the rest of the run. Every fixture used to verify
  this class's own row/cell rewrite uses inline strings instead (`caxlsx` can't
  generate the shared-string shape at all), so this was never exercised by that work
  - confirmed separately, with a hand-built fixture: +186.2MB for 300,000 unique
  strings. Deliberately left unfixed for now (see FINDINGS.md for the two fix options
  weighed and why neither was built yet) - worth revisiting if a real file with a
  large, mostly-unique shared-string table shows up in practice.

