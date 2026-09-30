# Importer Requirements

Point-form specification of every rule this class follows, organized by topic - what the
system does, not why. For the reasoning, evidence, and exact test results behind each
rule, see [FINDINGS.md](FINDINGS.md). For what each write mode (`raw_insert_all`,
`raw_upsert_all`, `activerecord`, `activerecord_import`, `raw_copy`) can and cannot do,
see [README.md](README.md#modes) - not duplicated here.

## General (applies regardless of mode or file format)

- `target_model`, `mode`, and `required_headers` must all be declared - `import!` raises
  at config time if any is missing, or if `mode` isn't one of `SUPPORTED_MODES`.
- Format dispatch (CSV/TSV vs. Excel) is internal only - a subclass never declares which
  format parser is in play. `file_path`'s own extension is the single source of truth,
  auto-detected the same way `.csv` vs `.tsv` already is. A subclass can read this
  decision back via `file_format`, callable from any `cast_<attribute>`, `exclude_row?`,
  `on_row_skip`, `before_batch`, or `after_batch` - returns `:csv`, `:tsv`, or `:xlsx`.
- `required_headers` maps header text to a model attribute. Column order in the file
  doesn't matter. Header matching is whitespace-tolerant on both sides.
- The file can have more columns than `required_headers` maps - only mapped columns are
  ever cast or written.
- `skip_file_validation` (default `false`) skips the whole-file structural check
  (the parser's own `validate_file!` - a UTF-8 scan for `.csv`/`.tsv`, a ZIP-signature
  check for `.xlsx`) - never header
  verification, which always still runs (`required_headers` can differ across importers
  sharing one `file_path`). Meant for several importer subclasses processing the
  identical `file_path` in one run - the first one already paid for the structural
  check, so later ones can skip paying for it again. Only a genuine saving for
  `.csv`/`.tsv` on a *valid* file; for `.xlsx` the skipped check is already the cheapest
  part (the real cost, opening the workbook, is triggered by header verification
  regardless). On an invalid file, this only defers the failure to a later, less clear
  error, not this class's own - see FINDINGS.md.
- `derived_attributes` (default `[]`) declares attributes written on every row that have
  no source column in the file at all - their value comes entirely from that attribute's
  own `cast_<attribute>` override, called with `nil` as its raw value. Rules:
  - The `cast_<attribute>` method must exist, or config time raises: a derived attribute's
    raw value is always `nil`, so the default caster would return `nil` and silently write
    `NULL` on every row.
  - The same attribute may not be both mapped in `required_headers` and declared derived -
    that raises rather than resolving by precedence.
  - Derived attributes are cast *after* every mapped one, so their `cast_<attribute>` can
    read any mapped column via `raw_value_for`. `raw_value_for` on a *derived* attribute
    still raises - it has no header to read.
  - They count as written attributes everywhere it matters: writability (below), the
    primary key guard, `unique_by`'s "conflict target must actually be written" check, and
    `activerecord_import`'s update-on-conflict column list.
  - If a derived attribute *is* the primary key, the same blank-value rule as a mapped one
    applies - a blank cast result drops the key entirely rather than writing `NULL`.
- `resolve_belongs_to :<foreign_key>, by: :<key_column>` (default: none) declares that a
  mapped foreign-key column holds the associated record's natural key in the source file,
  and resolves it to that record's id before writing. Rules:
  - The foreign key must be mapped in `required_headers` - there is nothing to resolve
    without a source column, so a derived attribute can't be one.
  - It must be the foreign key of a real `belongs_to` on `target_model`; that reflection is
    what determines which model to look the value up in. Never inferred by stripping `_id`,
    so an association named differently from its foreign key (or one with a `foreign_key:`
    override) resolves with no extra declaration.
  - `by` must be a real column on the associated model.
  - Declaring both `resolve_belongs_to` and a `cast_<foreign_key>` for the same attribute
    raises - both answer the same question.
  - A blank source value resolves to `nil`; whether that's acceptable is left to the
    column's `NOT NULL` constraint or the model's own validation. A **present** value that
    matches no record raises, reported with the line number and column like any other cast
    failure - which means it aborts the run even under `on_failure :skip`, the same as every
    other cast failure.
  - Lookups are cached per (attribute, value) for the whole run - one query per distinct
    value, not per row. Misses aren't cached, since a miss ends the run.
- For every mode except `activerecord`, every written attribute - `required_headers`-mapped
  or derived - must be a real column on `target_model`. Only `activerecord` may also write
  a hand-written writer method.
- Every value is strictly cast before being written, regardless of mode. A subclass
  overrides the default cast for one column with `cast_<attribute>`. The default caster
  only covers `:integer`, `:decimal`/`:float`, `:date`/`:datetime`, `:boolean`, and
  `:string`/`:text` (a no-op) - a column of any other type (`:json`/`:jsonb`, an array
  or enum column, a PostGIS geometry column) raises unless a subclass defines
  `cast_<attribute>` for it; there is no silent passthrough for an unhandled type. A
  virtual/writer-method attribute (`activerecord` mode only) is exempt from this and
  always receives its raw value untouched - the writer method is responsible for its
  own parsing.
- A `:decimal` column's own `scale` (when declared) is enforced by this class, not left
  to ActiveRecord/Postgres: a value with more fractional digits than the column's scale
  allows raises, for both a native Excel `Float` and a parsed CSV/text value - it is
  never silently rounded. A `:decimal` column declared with no scale (arbitrary
  precision) never raises for this, regardless of how many decimal places a value has.
- `raw_value_for(:attribute)` reads another *mapped* column's raw value, by attribute
  name - raises if the attribute isn't in `required_headers`.
- `raw_header_value('Header Text')` reads *any* column's raw value, by exact header
  text, mapped or not - returns `nil` if the header doesn't exist, rather than raising.
- `unique_by` (a column, an array of columns for a composite key, or an index name) is
  one concept shared across modes: required for `raw_upsert_all`; optional for
  `activerecord` and `activerecord_import` (insert-or-update if declared, always-insert
  if not). Must resolve to a real unique index; validated at config time regardless of
  which mode uses it.
- `on_failure` is `:rollback` (default) or `:skip`. Only `activerecord` and
  `activerecord_import` support `:skip` - declaring it on a mode that doesn't raises at
  config time. Each mode's `:skip` covers a different, specific scope - see README.md's
  Modes section.
- `batch_size` (default `1_000`) groups rows for every mode, including `activerecord`,
  which still saves one row at a time within a batch rather than issuing one bulk
  statement for it.
- `strip_raw_value` (default `true`) strips leading/trailing whitespace from every raw
  `String` value before it's cast or exposed via `raw_value_for`/`raw_header_value`.
  Disabled per-subclass with `strip_raw_value false`.
- `drop_blank_rows` (default `true`) silently skips a row where every field is blank -
  not counted toward `processed_count` or `#logs`. Disabled per-subclass with
  `drop_blank_rows false`.
- `exclude_row?(row)` (default: excludes nothing) lets a subclass exclude a row
  entirely, before any cast or write is attempted, based on its own business rule -
  distinct from `drop_blank_rows` (data hygiene) and `on_failure :skip` (a row that
  failed once attempted). `row` is every column in the file for that row (mapped in
  `required_headers` or not), keyed by stripped header text. Excluded rows are counted
  separately via `@excluded_count`, shown as `excluded: N` in the summary log entry,
  distinct from `processed`/`written`/`skipped`. `raw_value_for`/`raw_header_value`/
  `rich_text_header_value` are all safe to call from within `exclude_row?`, not just from
  a `cast_<attribute>` override - they read the current row being decided on, the same as
  `row` itself does.
- `#logs` is a plain, JSON-safe array of hashes. File-level problems (bad UTF-8, missing
  headers) raise with `#logs` left empty. Row-level problems (a bad cast, a DB write
  failure) both raise *and* leave a structured log entry (row number, column if
  applicable, message). The final entry is always a summary: `processed`, `written`,
  `skipped`, `excluded` counts.
- `on_row_skip(line_number:, attrs:, message:)` (default: no-op) is called each time a
  row is actually skipped - only reachable when `on_failure :skip` drops a row, which
  itself is only ever possible for `activerecord`/`activerecord_import` (the raw_* modes
  can't configure `:skip` at all, rejected at config time). Never called for an
  `on_failure :rollback` failure - that raises immediately instead of ever reaching a
  skip decision. Covers every way a row can be skipped under `:skip`, not just a
  validation failure - including a primary-key-protection drop
  (`allow_primary_key_write false` rejecting a row whose given id doesn't match an
  existing record).
- `before_batch(batch)`/`after_batch(batch)` (default: no-op) fire once around every
  non-empty batch write, right before/after it - never for an empty batch (there is
  nothing to observe). `batch` is the same `[{line_number:, attrs:, row:}]` Array
  `write_batch` itself receives, where `:row` is the raw row Hash that produced the item -
  every column the file had, not only the ones `required_headers` maps, so a subclass can
  act on a column it deliberately left unmapped (one cell naming several things, say, whose
  join rows it then writes itself now that the record's own id is known). A row that was
  skipped (`activerecord`/`activerecord_import` under
  `on_failure :skip`, possibly in the same batch as written rows) never gets
  `:primary_key_value` - it was never written.
  **`:primary_key_value` is resolved by value, never by position** (see FINDINGS.md for
  why the original position-based approach - matching a row to its primary key by index
  in `insert_all!`/`upsert_all`'s `RETURNING` result - was replaced): populated only when
  the row's own attrs already included the primary key directly
  (`allow_primary_key_write true`), or when `unique_by` is declared (one extra query per
  batch, matched back by the natural key's own value - correct for an update via
  `unique_by` just as much as a fresh insert). **Not populated at all** for a "blind"
  bulk insert (`raw_insert_all`, no `unique_by`, no explicit primary key) - nothing
  reliable to correlate a row to its generated id by - nor for two rows in the same
  batch sharing the same (possibly null) `unique_by` value - no way to tell which
  generated id belongs to which of them. This mechanism is a plain `SELECT`/`pluck`, so
  unlike the original approach it is fully adapter-independent - works identically on
  PostgreSQL, MySQL, MariaDB, SQLite (verified directly against this app's own
  `wordpress:` MySQL connection) - **for the resolution mechanism itself.** `raw_upsert_all`
  still can't run at all on MySQL/MariaDB regardless (its `unique_by`/`ON CONFLICT`
  mechanism requires `supports_insert_conflict_target?`, which only PostgreSQL/SQLite
  implement) - a pre-existing limitation of the mode itself, not of this resolution
  logic. Matching in `assign_primary_key_values_by_unique_key!` also uses Ruby's own
  equality, not the database's - a `unique_by` column whose collation makes the
  database compare values differently than Ruby's `==` (case-insensitively, e.g.) can
  leave `:primary_key_value` unset for a row that was, in fact, found and correctly
  written - safe (never a wrong value), but incomplete for that column configuration.
  See FINDINGS.md for both.
- `activerecord_import` with `unique_by` declared raises at config time
  (`assert_activerecord_import_upsert_supported!`) against a connection the installed
  `activerecord-import` gem cannot build an upsert for - confirmed this affects MySQL
  specifically: the gem's own MySQL adapter extension never actually gets mixed into
  the connection class under this app's installed Rails/gem versions, a gem defect, not
  something fixable by changing the option shape this class builds (which is otherwise
  already adapter-aware - see FINDINGS.md). Raised only for this one combination - a
  plain insert via `:activerecord_import` (no `unique_by`) still works correctly on
  MySQL.
- If a subclass override of `on_row_skip`/`before_batch`/`after_batch` raises, it
  propagates unmodified and rolls back the whole run - every call site already runs
  inside `import!`'s own transaction, the same as any other in-batch failure. No
  `before_import`/`after_import` lifecycle hooks exist, deliberately: they would only
  wrap the entire `import!` call, which a caller already fully controls just by writing
  code immediately before/after `SomeImporter.new(file_path:).import!`.

## Primary key handling

- `allow_primary_key_write` (default `false`) gates whether a caller-supplied primary key
  value can be *written* (used to insert a new row) - never whether it can be *mapped or
  looked up*. Reading/matching by primary key is always allowed, in any mode with a
  lookup step, regardless of this setting.
- This gate is entirely type-agnostic - it doesn't care whether the primary key is an
  auto-incrementing integer or something else entirely, e.g. a client-generated UUID.
  Verified directly, in all 4 implemented modes: `allow_primary_key_write true` plus a
  `cast_id` override (needed because `:uuid` isn't one of the default caster's covered
  types - the same "unsupported type raises, define `cast_<attribute>`" rule as
  `:jsonb`/an array/enum column, not a UUID-specific exception) inserts each row with
  its own exact supplied UUID, and correctly resolves `:primary_key_value` to that same
  UUID in `after_batch`, in every mode:
  ```ruby
  class SomeImporter < Importer::Base
    target_model SomeModel
    mode :raw_insert_all # or :raw_upsert_all / :activerecord / :activerecord_import
    allow_primary_key_write true
    required_headers({ 'Id' => :id, 'Name' => :name })

    def cast_id(raw_value)
      raw_value # or validate/normalize the UUID string here
    end
  end
  ```
- A blank primary key value in the source never attempts a lookup, and is never treated
  as a caller-supplied value to protect against - the attribute is omitted entirely from
  the write (not passed through as an explicit `nil`, which would violate the column's
  `NOT NULL` constraint) so the database's own default/sequence assigns it. This holds
  regardless of `allow_primary_key_write`.
- Whenever `allow_primary_key_write` is `true`, `import!` resyncs the primary key's
  underlying Postgres sequence to `MAX(id)` once, after the whole run succeeds
  (`connection.reset_pk_sequence!`) - writing an explicit id never advances a `SERIAL`/
  `IDENTITY` column's own sequence, in any mode, so without this a later, unrelated plain
  `Model.create!` elsewhere in the app can collide with an id this class already wrote
  manually. No-op (not an error) when there's nothing to resync: a non-Postgres adapter
  (the method doesn't exist there - MySQL's `AUTO_INCREMENT` already self-adjusts, unlike
  a Postgres sequence), a primary key with no sequence at all (e.g. a UUID column), or an
  empty table. See FINDINGS.md for the reproduction and why this needed fixing.
- **Known, deliberately accepted limitation**: the resync above runs after the run's own
  transaction has already committed, on purpose - not folded into it. If the resync
  itself fails (a transient connection blip, a lock timeout - not something expected in
  ordinary operation, but not impossible either), `import!` still reports success, since
  the rows genuinely are durable and safe to leave as committed - but the sequence stays
  desynced, and the actual hazard this feature exists to prevent (a later, unrelated
  `Model.create!` colliding with an id this run wrote manually) is still fully live until
  some other run's own resync happens to succeed later. The only signal is a
  `level: 'warning'` entry in `#logs`. See FINDINGS.md for why this was decided over the
  alternative (making the resync part of the same transaction).
- `raw_copy`'s specific behavior isn't decided yet.

| Mode | `allow_primary_key_write` | PK value in source | Result |
|---|---|---|---|
| `raw_insert_all` | `false` (default) | any | raise at config time - no lookup step exists, so any PK use is a write |
| `raw_insert_all` | `true` | empty | attribute omitted from the row -> DB default/sequence assigns it |
| `raw_insert_all` | `true` | provided | inserted as given; DB raises on collision (no lookup, no update path) |
| `raw_copy` | - | - | not decided yet |
| `raw_upsert_all` | `false` (default) | empty | attribute omitted -> DB default/sequence assigns (plain insert) |
| `raw_upsert_all` | `false` (default) | provided | lookup by PK - found -> update; not found -> raise, per-row at runtime, subject to `on_failure` |
| `raw_upsert_all` | `true` | empty | same as `false` + empty |
| `raw_upsert_all` | `true` | provided | lookup by PK - found -> update; not found -> insert with the given PK |
| `activerecord` | `false` (default) | empty | no lookup attempted, fresh record built with no id set -> DB default/sequence assigns on save |
| `activerecord` | `false` (default) | provided | `find_or_initialize_by(id: X)` - found -> update via `save!`; not found -> raise, per-row at runtime, subject to `on_failure` |
| `activerecord` | `true` | empty | same as `false` + empty |
| `activerecord` | `true` | provided | `find_or_initialize_by(id: X)` - found -> update; not found -> `save!` proceeds, inserting with id = X |
| `activerecord_import` | `false` (default) | empty | id attribute omitted from `target_model.new(attrs)` -> DB default/sequence assigns on insert |
| `activerecord_import` | `false` (default) | provided | pre-batch guard (new) - found -> stays in batch, `on_duplicate_key_update` updates it; not found -> filtered out before `.import`, logged as a row failure, subject to `on_failure` |
| `activerecord_import` | `true` | empty | same as `false` + empty |
| `activerecord_import` | `true` | provided | found -> update via `on_duplicate_key_update`; not found -> no guard needed, proceeds into the bulk `import`, inserts with the given id |

`raw_upsert_all` and `activerecord_import` both write via one bulk SQL statement per
batch, so - unlike `activerecord`'s `find_or_initialize_by`, which already performs this
check per row for free - neither can tell found from not-found before the statement
runs. Both need a shared pre-batch guard (one `SELECT` for the primary keys already
present in the batch) to enforce the `allow_primary_key_write false` raise case. The
guard is only needed when `allow_primary_key_write` is `false` - a `true` not-found case
just falls through to a normal insert, which the bulk statement already performs
unassisted.

## CSV / TSV

- `file_path` must end in `.csv` or `.tsv` - any other extension raises before any file
  I/O happens.
- `.tsv` always uses tab as its delimiter - never comma or semicolon, not configurable.
  The extension alone is the signal.
- `.csv` uses comma by default, or semicolon if the subclass declares
  `csv_delimiter ';'`. No other delimiter is supported for `.csv` - declaring one raises
  at config time. A `csv_delimiter` declaration has no effect on a `.tsv` file (not an
  error to declare both on the same class - the same class could run against either
  extension across different calls).
- Quoting follows RFC 4180's double-quote convention only, regardless of which delimiter
  is in use. A field containing the delimiter must be wrapped in double quotes
  (`"aaa,bbb"`) - the only escaping mechanism understood. A bare backslash before a
  delimiter (`aaa\,bbb`, unquoted) is *not* treated as an escaped delimiter.
- UTF-8 (with or without a leading BOM) by default - any other encoding raises before
  any row is processed. A subclass can declare `csv_encoding 'Windows-1252'` (or any
  encoding Ruby's `Encoding::Converter` can transcode to UTF-8 - `Encoding.name_list`)
  to read a source file in that encoding instead; every row is transcoded to UTF-8 on
  the way in, so nothing downstream of parsing ever sees anything but UTF-8. An unknown
  encoding name raises at config time (`Encoding::Converter.new` is used to check it
  up front); a byte that doesn't fit the declared encoding raises during the pre-pass,
  naming the line, the same as the default UTF-8 check does. Deliberately not a
  generic passthrough of arbitrary CSV-parser options (quote character, liberal
  parsing, etc.) - only the encoding is exposed, since `headers: true` and the
  `.tsv`-forces-tab rule are load-bearing invariants a fuller passthrough could
  silently defeat.
- The first row must be a header row - not configurable; no headerless/positional file
  support.
- A required header appearing more than once in the file raises. A *non-required*
  header appearing more than once is not checked - the second one silently wins if a
  subclass ever inspects it via `raw_header_value`/`exclude_row?`.

## Excel (.xlsx)

- Only `.xlsx` is supported. Legacy `.xls` (the pre-2007 binary format) is out of scope,
  permanently.
- `file_path` must end in `.xlsx`, and the file's first 4 bytes must match the ZIP
  signature (`PK\x03\x04`) - a file merely *named* `.xlsx` that isn't actually a ZIP
  archive raises, before any further parsing is attempted.
- One sheet only per import run - never combining or iterating multiple sheets.
  `sheet_name` selects a specific one; defaults to the first sheet if not declared.
  Declaring a `sheet_name` that doesn't exist in the workbook raises.
- `header_row` (default `1`, 1-indexed to match Excel's own row numbering, not
  0-indexed) - which row is the real header row. Must be a positive integer.
- `data_start_row` (default `header_row + 1`, independently overridable) - which row
  real data starts on. Must be a positive integer, and must be after `header_row`.
- A merged cell in the header row raises. A merged cell in a decorative row above the
  header (skipped via `header_row`/`data_start_row`) is not a problem - that row is
  never read at all. A merged cell in a data row also raises - the same safe default as
  the header row, not a considered design for the data-row case specifically (see
  FINDINGS.md).
- Formula cells always use the calculated value - not configurable, no option to read
  the raw formula text instead. This requires no dedicated implementation: it's simply
  what a normal cell-value read already returns, since nothing in this class ever asks
  for a cell's formula text specifically.
- A cell's native type (`Integer`/`Float`/`Date`/`TrueClass`/`FalseClass`) is used
  directly, unchanged, when it already matches the target attribute's expected type - no
  re-parsing, no precision-loss risk. Otherwise (a `String` cell, or a native type that's
  the wrong one for that column) it's stringified and run through the same cast pipeline
  CSV already uses - a genuine mismatch fails exactly the way a bad CSV value would,
  deliberately including a whole-number `Float` (e.g. `42.0`) mapped to an `:integer`
  column - see FINDINGS.md for why this isn't treated as a native-type match, and the
  `cast_<attribute>` workaround for a subclass that needs it accepted anyway. A literal
  `false` cell value is never treated as blank (see FINDINGS.md for why this needed an
  explicit fix).
- Row/cell reading is memory-bounded - one row's own XML at a time, never the whole
  sheet loaded into memory at once - the same property CSV/TSV already has via
  streaming. Not something `roo`'s own row-access API provides on its own (its `.row(n)`
  eagerly extracts every cell on the sheet into memory the first time any row is
  touched). `roo` does have a genuinely streaming API too (`each_row_streaming`), but
  it isn't used directly - it doesn't pad a row's own missing trailing cell, it
  silently skips a row missing from the XML entirely instead of reporting the gap, and
  its own internals aren't hardened against a cell missing its own `r` attribute or a
  namespace-prefixed sheet, both cases this class already has regression coverage for.
  This class reads the raw sheet XML directly instead, handling all of that itself,
  and reuses `roo` only for per-cell value typing. See FINDINGS.md for the measured
  memory difference and each gap found.
- **Known limitation, not yet fixed**: the above covers row/cell *structure* only.
  Shared-string *value* resolution (a cell's actual text, when the workbook uses
  OOXML's shared-string table rather than inline strings - the default for real
  Excel/Google Sheets/LibreOffice output) is still `roo`'s own responsibility, and
  `roo` loads that entire table into memory via one full DOM parse the first time any
  shared-string cell is read - not bounded by row count, growing instead with the
  number of *unique* strings in the workbook. Confirmed directly (+186.2MB for 300,000
  unique strings in a hand-built fixture); left unfixed deliberately for now. See
  FINDINGS.md for the investigation and the two fix options weighed.
- Rich-text (per-run formatting) fidelity is implemented - see below.

### Rich text

- A subclass declares, upfront, which columns need rich-text (per-run formatting)
  fidelity, via `rich_text_headers ['Some Header', ...]` - by exact header text, the
  same convention `raw_header_value` uses, not `required_headers`'s "header text ->
  attribute" mapping (a Symbol or untrimmed entry is tolerated the same way
  `required_headers`/`raw_header_value` already tolerate stray whitespace). Not
  discoverable lazily from inside `cast_<attribute>`: the batched extraction needs to
  know every target column before the SAX stream starts. A rich-text header need not
  also be in `required_headers` - the same "any column, mapped or not" allowance
  `raw_header_value` already has.
- `rich_text_header_value('Some Header')`, called from inside a `cast_<attribute>`
  override, returns that row's rich-text data for the declared header as a Hash:
  `{ runs: [...] or nil, background_color: {...} or nil }`.
  - `runs` is an Array of `{ text:, bold:, italic:, strikethrough:, underline:, size:,
    color:, font:, vertical_align:, outline:, shadow:, condense:, extend:,
    font_family:, charset:, font_scheme: }` Hashes, one per run, in source order, or
    `nil` for a genuinely blank cell. A plain
    (non-rich) string cell, or any other populated cell type (numeric, boolean, date,
    error, or a formula's cached string result) still comes back as a single unstyled
    run, not a bare value or `nil` - so a caller never has to special-case "was this
    cell actually rich, or just plain, or not text at all".
    `bold`/`italic`/`strikethrough`/`outline`/`shadow`/`condense`/`extend` are
    booleans; `underline` is `nil` (no underline) or a Symbol style
    (`:single`/`:double`/`:singleAccounting`/`:doubleAccounting`); `size` is `nil` or a
    Float point size; `font` is `nil` or the run's font name String; `vertical_align` is
    `nil`, `:superscript`, or `:subscript`; `color` is `nil` or a Hash of whichever of
    `rgb`/`theme`/`indexed`/`tint`/`auto` OOXML actually recorded for that run (see
    below).
  - `background_color` is the cell's own fill, or `nil` for no fill at all
    (`patternType="none"`, the default, or the attribute absent entirely). This is a
    *per-cell* property, not per-run - OOXML has no concept of a per-character cell
    background, so it's independent of `runs` entirely: a completely blank cell can
    still have a `background_color` if it was colored with no text in it. Any other
    `<patternFill>` (`solid`, or a striped/hatched pattern like `darkGray`) resolves to
    `{ pattern_type:, fg_color:, bg_color: }` - both colors, not just the foreground,
    since a non-solid pattern's visible appearance is a genuine two-color mix. A
    `<gradientFill>` resolves to `{ pattern_type: :gradient }` only - a marker, not
    its actual color stops/angle/path, which aren't extracted (see below).
  - A run's `color`, and a pattern fill's `fg_color`/`bg_color`, all share the same
    Hash shape: whichever raw attribute OOXML recorded (`rgb:` a hex string, `theme:`
    a palette index, `indexed:` a legacy palette index, `auto:` `true` for "renderer's
    choice", plus an optional `tint:`) rather than a single resolved RGB value -
    resolving a `theme`/`indexed` reference to an actual color requires parsing the
    workbook's theme XML (or the legacy fixed palette), which isn't done.
  - A bare `nil` (not the Hash above) means any of: a declared header that isn't
    actually present in this particular workbook's header row (a typo, or simply a
    file that doesn't have this column) - the same "declared but not found" outcome
    `raw_header_value` already has for any header; a row that never had a cell element
    for this column at all; or - consistent with that same "not found -> nil"
    convention, not a raise - a non-`.xlsx` import (the feature is Excel-only; a
    CSV/TSV cell is always a plain string already, with no rich-text concept to
    extract). Still raises for a header never declared via `rich_text_headers` at all -
    a caller mistake (a typo in the subclass's own code), not a per-row data issue,
    kept distinct from every "nothing to report" case above.
- `cast_<attribute>`'s own `raw_value` argument is unaffected - always the plain,
  flattened text, exactly as before this feature existed. Rich-text data is a separate,
  explicit, opt-in lookup, not folded into the value a default/overridden cast receives.
- Rich-text extraction is batched by the same `batch_size` (row count) already used by
  the main import loop - not a separate byte-size target. Deliberate simplicity: a
  single very large cell can still spike memory within its own batch, since row count
  alone doesn't bound how much any one cell contains - mitigated by a developer manually
  configuring a smaller `batch_size` for an import known to have large cells, not by
  automatic size-adaptive batching. A byte-size-based approach was investigated and
  confirmed to work (see FINDINGS.md), but wasn't adopted for this reason.
- A cell's rich-text runs are read whether they're stored inline in the sheet itself
  (`t="inlineStr"`) or via a numeric reference into the workbook-wide shared-string
  table (`t="s"`, resolved against `sharedStrings.xml`) - OOXML permits either
  representation for any string cell, and a real (non-`caxlsx`-generated) workbook
  commonly uses the latter. See FINDINGS.md for the caveat on how thoroughly each path
  has actually been verified. A formula cell whose cached result is a string
  (`t="str"`) is also handled - its result is always a single unstyled run (never rich
  text - a formula's computed value has no per-character formatting of its own).
- A cell with **no rich-text run of its own** (a bare string/numeric/boolean/date/
  error/formula-result value) still falls back to its own cell style's font (every
  property `runs` can hold: bold, italic, underline, strikethrough, size, color, font
  name, vertical alignment, outline, shadow, condense, extend, font family, charset,
  and theme-font scheme) - e.g. a whole cell made bold via "Format Cells" rather than a
  rich-text run reports `bold: true`, not the default `false`. A cell that **does**
  have its own rich-text run(s) is never affected by this - its own run(s) are used
  exactly as written, with no merging from the cell's style. See FINDINGS.md for why
  this fallback is deliberately scoped to "no run at all", not full per-property
  inheritance for a cell that does have runs.
- `font_family`/`charset`/`font_scheme` are also extracted per run (and as part of the
  cell-level-style fallback for a plain cell): `font_family` is `nil` or an Integer
  (font pitch/serif classification) and `charset` is `nil` or an Integer (the
  character set the named font was authored for) - both are fallback-substitution
  hints, used only to help pick a replacement font when the named one isn't
  available, not directives that change how the run's own (always-Unicode) text is
  interpreted or displayed; `font_scheme` is `nil`, `:major`, or `:minor` (which
  workbook theme font a run uses when it has no explicit font name of its own - this
  one genuinely determines what actually renders, not just a fallback signal).
- Not extracted at all:
  - Per-*property* inheritance from a cell's style into a run that specifies some but
    not all of its own properties - a run with `<rPr><b/></rPr>` and no other property
    is treated as bold with everything else at its default, not as "bold, but italic/
    color/etc inherited from the cell" - see FINDINGS.md for why.
  - A gradient fill's actual color stops, angle, or path (`<gradientFill>`'s own
    children) - only that it *is* a gradient (`{ pattern_type: :gradient }`).
- A phonetic-hint run (`<rPh>` - Japanese furigana, most commonly) is excluded from
  `runs` entirely, for both inline and shared strings - it's a pronunciation aid for a
  range of the base text, not itself part of that text.
