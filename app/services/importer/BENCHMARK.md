# Importer::Base - measured limits per mode

How many rows one `import!` call can handle, measured rather than estimated - per write
mode for CSV/TSV, then per format property for `.xlsx`, whose limit is set by the file
format rather than by the mode. Reproduce with `benchmark/importer/` (see the bottom of this
file); the harness prints the same tables this document is written from.

**Recommend and think in rows, not file size.** Nothing in this class scales with file
bytes. Peak memory is set by row *width* times `batch_size` (each live batch item retains
both its cast `:attrs` and the raw `:row` Hash of every column in the file), plus whatever
grows per row - never by how long the file is. A 200MB file of narrow rows and a 200MB
file of 40-column rows behave completely differently at the same byte count.

## The numbers (CSV/TSV)

Measured on PostgreSQL 18.3, Ruby 3.4.9, Rails 8.1.3, default `batch_size` (1,000), a
7-column CSV writing 7 real columns (varchar/text/integer/numeric/boolean/date). Rails
boot alone is ~110MB RSS; "peak" below is *above* that baseline. "MB/100k" is the fitted
slope of peak RSS against row count - the honest measure of what a mode retains per row.

| mode | rows/sec | peak RSS @ 1M rows | MB per 100k rows | XIDs consumed | memory-bounded? |
|---|---|---|---|---|---|
| `raw_insert_all` | ~12,000 | 12MB | 0.1 | 1 per batch | yes - flat |
| `raw_upsert_all` | ~11,000 | 14MB | 0.3 | 1 per batch | yes - flat |
| `activerecord_import` | ~6,300 | 18MB | 0.1 | 1 per batch | yes - flat |
| `activerecord` | ~800 | (3GB @ 500k) | **577** | **1 per row** | **no - linear** |

Three of the four modes are genuinely flat: `raw_insert_all` measured 12.3MB at 10,000
rows and 12.3MB at 1,000,000 rows. Their ceiling is not a memory question at all.

`:activerecord` retains **~5.8MB per 1,000 rows** for the whole run, linearly, and reached
3,033MB at 500,000 rows.

## Recommended maximum rows per `import!`

| mode | recommended max | hard stop | what binds first |
|---|---|---|---|
| `raw_insert_all` | 5,000,000 | none from memory | wall time (~7 min/5M), transaction duration |
| `raw_upsert_all` | 5,000,000 | none from memory | as above, plus dead-tuple bloat that cannot be vacuumed until commit |
| `activerecord_import` | 3,000,000 | none from memory | wall time (~8 min/3M) |
| `activerecord` | **50,000** | **200,000** | RSS, linearly; also 1 XID per row |

For the three flat modes the "recommended max" is a *duration* judgement, not a memory
one - 5M rows is roughly 7 minutes in one transaction, which is already long enough for
the vacuum-horizon and DDL-blocking effects to matter. Nothing breaks above it; the run
just holds a transaction open longer, and a failure at the end discards more work.

For `:activerecord`, derive your own number if the container budget differs -
`(budget_MB - 110) / 5.8` gives thousands of rows. Measured fits:

| container RSS budget | max rows, `:activerecord` |
|---|---|
| 512MB | 39,000 |
| 1GB | 128,000 |
| 2GB | 306,000 |
| 4GB | 661,000 |

The 50,000 recommendation is the 512MB figure with headroom, because `:activerecord` is
also ~15x slower than `raw_insert_all` (800 vs 12,000 rows/sec), so a file large enough to
threaten memory is already a multi-minute import.

## Why `:activerecord` grows, and why you cannot fix it on the model

`write_row_activerecord` wraps every row's `save!` in its own savepoint
(`transaction(requires_new: true)`). ActiveRecord normally avoids retaining saved records
when a transaction is already open: `with_transaction_returning_status` passes
`ensure_finalize = false` (`activerecord/lib/active_record/transactions.rb:435`), which
enrolls the record into an `ObjectSpace::WeakMap` instead of a strong array, so it stays
collectable.

**The per-row savepoint defeats that.** When each savepoint commits, `commit_records` calls
`records`, which merges the WeakMap straight into the strong `@records` array
(`abstract/transaction.rb:230-236`), then re-enrolls every record into the *parent*
transaction with the default `ensure_finalize = true`
(`abstract/transaction.rb:321-324`). So each record becomes strongly held by the outer
run-long transaction the moment its own savepoint commits, and stays held until `import!`
returns.

This is confirmed by measurement, and it corrects a plausible-sounding but wrong
explanation: a model with an `after_commit` callback measured 628MB/100k against 577MB/100k
for one with no transactional callbacks at all - only ~9% apart. Transactional callbacks
are **not** the cause. Removing `has_one_attached` or an `after_commit` from the target
model will not help. (Worth knowing anyway: `has_one_attached` *does* install an
`after_commit`, so almost any model with an attachment - `Post` included - has
transactional callbacks whether or not anyone intended it.)

The same per-row savepoint is also why `:activerecord` consumes one XID per row (500,050
XIDs for 500,000 rows, vs 1,009 for the same file through `raw_insert_all`) and why it
generates a subtrans SLRU hit per row. A backend caches only 64 subtransaction ids in
shared memory, so past 64 rows the array overflows and other backends must resolve
visibility through `pg_subtrans` - a cluster-wide cost, not a cost to this session.

## Two things that change the numbers

**Row width is a constant cost, not a per-row one.** A 40-column file (7 mapped, 33
unmapped - unmapped columns still land in the `:row` Hash) added ~18MB flat and cost ~35%
throughput: `raw_insert_all` went from 12.3MB/12,800 rows/sec to 30.2MB/8,000 rows/sec, and
crucially 30.2MB at 1M rows was the same as 29.4MB at 200k. Row width raises the plateau;
it does not tilt it. Very wide files or very large cells are handled by lowering
`batch_size`, not by lowering the row count.

**A high-cardinality `resolve_belongs_to` is the one thing that makes a flat mode
unbounded.** `@belongs_to_lookup_cache` never evicts, so it holds one entry per distinct
natural key for the whole run:

| `resolve_belongs_to` shape | rows/sec | MB per 100k rows |
|---|---|---|
| low cardinality (200 distinct parents) | 12,000 | 0.5 - flat |
| high cardinality (unique parent per row) | 2,000 | 16.3 - linear |

So a near-unique lookup column costs 6x throughput *and* turns `raw_insert_all` into a
linear-memory mode (a ~2.3M row ceiling at 512MB). Low-cardinality lookups - the shape the
cache was designed for - are free. If a lookup column is near-unique per row, the mode's
row ceiling drops to roughly 2M and the import takes 6x longer.

## Why this was measured at all

The class streams its input - `CSV.foreach` and `File.foreach` read one row at a time, and
`flush_batch` caps live rows at `batch_size` - so "reading is memory-bounded" was already
true and already documented (see README.md). What was *not* established is that a whole
`import!` **run** is bounded, which is a different claim: a streaming reader says nothing
about what the write path, the caches, or ActiveRecord itself retain while the run's single
transaction stays open.

Reading the code turned up four candidates that grow with row count rather than with the
live batch - `@logs` under `on_failure :skip`, `@belongs_to_lookup_cache`'s never-evicting
per-distinct-value entries, ActiveRecord's own record enrollment in the enclosing
transaction, and the per-row savepoint in `:activerecord` mode. Each was arguable from the
source, and at least one plausible-looking conclusion drawn that way turned out to be wrong
(see "Why `:activerecord` grows" above - transactional callbacks were blamed and are
measurably not the cause). So the point of the benchmark is not to confirm the reading; it
is to produce a number per mode that a developer can check their own file against, and to
let measurement overrule any reasoning that disagrees with it.

## How it was measured

**The unit is rows, and the reported quantity is a slope.** A single "peak RSS at N rows"
figure is close to meaningless here: it is dominated by the ~110MB Rails boot baseline, and
it cannot distinguish memory that is *retained* from allocation churn the GC simply had no
reason to reclaim yet. So every mode is run at several row counts and peak RSS is fitted
against row count by least squares. A slope near zero means the mode plateaus and is
genuinely bounded - its ceiling is then set by time or by Postgres, not by RSS. A real slope
means something is retained per row, and the row ceiling for any memory budget is
arithmetic. That is why the tables above report MB/100k rows and a budget-derived ceiling
rather than a single measured maximum.

**One fresh process per data point.** Peak RSS is read from `/proc/self/status`'s `VmHWM`,
the kernel's own high-water mark for the process, so no sampling thread is needed and no
peak can be missed between samples. Reusing a process across points would carry GC state
and ActiveRecord's schema cache into later runs and smear the curve, so each point is its
own `bin/rails runner` invocation. `baseline_rss_mb` is captured after boot and after a
`GC.start`/`GC.compact`, immediately before `import!`, and every peak in this document is
reported net of it.

**What each point resets.** `bench_rows` is truncated and `VACUUM ANALYZE`d before the
import, so no point inherits another's dead tuples or planner statistics, and every mode
does pure inserts (nothing measures an update path by accident).

**Metrics, and why each one is here.**

- Peak RSS above baseline, and `GC.stat[:heap_live_slots]` growth - the memory question
  itself, plus a second signal that distinguishes retention from churn.
- Wall time and rows/sec - because for three of the four modes this, not memory, is what
  actually bounds a run, so a memory-only benchmark would have produced no useful ceiling
  for them.
- XIDs consumed, via `pg_snapshot_xmax(pg_current_snapshot())` before and after. Note
  `pg_current_xact_id()` is deliberately *not* used: it assigns an XID to the measuring
  session and would corrupt its own measurement.
- `pg_stat_slru` subtrans reads/hits - the direct evidence for the per-row savepoint's
  cluster-wide cost, and the reason the `:activerecord` recommendation is about more than
  this process's RSS.
- WAL bytes and total relation size - so a mode's cost to the server is visible next to its
  cost to Ruby.

**Fixture profiles, each isolating one variable.**

- `narrow` - 7 columns, all mapped. The baseline shape.
- `wide` - the same 7 mapped columns plus 33 **unmapped** ones. Unmapped is the point:
  `row_hash` builds a Hash of every column in the file regardless of `required_headers`,
  and each batch item retains it as `:row`, so this measures row-width memory without
  changing how much cast work happens.
- `fk_low` / `fk_high` - a `resolve_belongs_to` column drawn from 200 distinct parents
  versus one unique parent per row. The pair is what separates "the cache works" from "the
  cache is unbounded"; either alone would prove nothing.

**Two model variants, `plain` and `cb`,** differing only by an `after_commit` callback, so
"cost of the mode" and "cost of the model" cannot be confused. This is the control that
falsified the callback explanation.

**`:activerecord` is run without `unique_by`** so all four modes are compared as pure
inserts. Declaring it would add a `find_or_initialize_by` SELECT per row, which is a
different measurement (a real one, just not this one).

**What these numbers do not cover.** `on_failure :skip` with a
high failure rate, which is the unbounded-`@logs` case, deliberately excluded because a
sensible fixture for it is a judgement call rather than a measurement. Non-default
`batch_size`. Concurrent imports sharing a connection pool. And these are single-run
figures, not averaged across repeats, so treat throughput as accurate to roughly ±10% and
the memory slopes - which are large and unambiguous where they exist at all - as solid.

## Excel (.xlsx)

Measured with `raw_insert_all` held constant, because the mode costs above are
format-independent (nothing in `loaders/` knows which parser produced a row) - so anything
that grows here is attributable to the `.xlsx` reader. Confirmed rather than assumed:
`activerecord_import` on a 200,000-row shared-string file peaked at 461MB against
`raw_insert_all`'s 468MB on the same file, so format cost and mode cost simply add.

| profile | 10k rows | 50k | 200k | 500k | MB/100k rows | rows/sec |
|---|---|---|---|---|---|---|
| inline strings | 33.7MB | 57.8 | 62.0 | 66.3 | ~0 (flat) | 5,300 |
| **shared strings** | 48.3MB | 136.2 | 468.2 | **1,027.2** | **199** | 5,900 |
| shared strings, fewer distinct | 30.3MB | 62.7 | 167.1 | - | 71 | 6,200 |
| rich text extraction | 43.1MB | 60.6 | 63.1 | - | ~0 (flat) | 3,900 |
| 40 columns, inline | 64.0MB | 68.0 | 73.3 | - | ~0 (flat) | **1,100** |

**Row and cell reading is bounded, exactly as README.md claims** - the streaming XML reader
holds 62MB at 200,000 rows and 66MB at 500,000. **The shared-string table is not**, and at
scale it is not merely the largest cost, it is essentially the *only* one: 1,027MB peak for a
500,000-row import, of which the shared-string load alone accounts for ~1,004MB (measured
in isolation below).

**The two shared-string rows are what identify the mechanism.** Memory scales with the
number of *distinct* strings, not rows: the `shared` fixture has 3 distinct strings per row
and slopes at 199MB/100k, while `shared_repeat` has ~1 and slopes at 71MB/100k - a ratio of
2.8 against an expected 3. Roughly 0.19KB retained per distinct string.

**Which means the inline-strings row is the unrealistic one.** Interactive Excel, Google
Sheets export and LibreOffice all route text through `sharedStrings.xml`; inline strings are
mostly what programmatic writers emit (`caxlsx`, this project's fixture generator, defaults
to them, which is why the shared variant had to be opted into). And the table is
deduplicated by definition - `<sst>` carries both `count` and `uniqueCount` - so its size is
a property of the data, not the writer. Note what that means in practice: `shared_repeat`
draws its text from a 200-value pool and *still* has 50,407 distinct entries, because its
natural-key column is unique per row. **Any import file with a natural key has at least one
distinct string per row**, so the small-table case is close to unreachable for real files.
Plan against the shared-strings row.

| container RSS budget | max rows, `.xlsx` with shared strings |
|---|---|
| 512MB | 181,000 |
| 1GB | 438,000 |
| 2GB | 952,000 |

Two smaller findings. **Column count is far more expensive in `.xlsx` than in CSV**: 40
columns cost 5x throughput (5,300 -> 1,100 rows/sec) against CSV's 35% for the same shape,
while memory stayed flat. A wide Excel file is a speed problem, not a memory one. And
**rich-text extraction is bounded** - flat memory across 10k-200k rows, for a 26% throughput
cost (5,300 -> 3,900 rows/sec), so `rich_text_headers` is cheap enough to leave declared.

### Recommended maximum rows for `.xlsx`

Unlike the CSV modes, an `.xlsx` limit cannot be one number per mode, because the cost is
driven by the shared-string table rather than by the write path - so it scales with how many
**unique-text columns** the file has, not with its row count alone. Two independently
measured profiles agree closely on the unit cost: 0.66MB per 1,000 rows per unique-text
column (3-column fixture) and 0.71MB (1-column fixture). Use **0.7MB**.

    peak RSS (MB) = 110 (Rails boot) + 41 + 0.7 x (rows / 1000) x unique-text columns

A "unique-text column" is a text column whose value is essentially distinct on every row -
a title, a description, a code, a UID, a slug. Columns drawn from a small vocabulary
(status, country, category, unit) cost nothing measurable, however many rows there are, and
numeric/date/boolean columns are not in the shared-string table at all. Count only the
former. A typical export has 3-4.

Recommended maxima below assume 3 unique-text columns and leave 30% of the budget as
headroom - for GC timing, the write mode's own ~18MB, and anything else in the process:

| container RSS budget | recommended max rows | hard ceiling (100% of budget) | covers any legal `.xlsx`? |
|---|---|---|---|
| 256MB | **15,000** | 53,000 | no |
| 512MB | **100,000** | 181,000 | no |
| 1GB | **280,000** | 438,000 | no |
| 2GB | **640,000** | 953,000 | no |
| 2.5GB | **790,000** | 1,048,575 (all) | at the limit, no headroom |
| 3.5GB | **1,048,575 (all)** | 1,048,575 (all) | yes |

Both columns are capped by the format itself: `.xlsx` holds at most 1,048,576 rows per sheet
(2^20), so no legal file can exceed 1,048,575 data rows and any figure above that is
unreachable rather than merely large. Two budgets follow from that, for the case where a
file's shape is not known in advance: **~2.24GB** is the point where the largest legal sheet
fits at all, and **~3.2GB** is where it fits with the same 30% headroom every other row of
this table assumes. Below ~2.24GB there exist legal `.xlsx` files this class cannot import,
whatever the row count of the ones you actually have.

For a file with more text columns, divide by the ratio: 6 unique-text columns halves every
number above, 12 quarters it. For a file whose text is genuinely categorical, the shared
table stays small and the `.xlsx` limit stops binding at all - the inline-strings row of
the table above (flat at ~66MB to 500,000 rows) is then the right expectation.

**One time-based caveat that overrides the memory numbers: column count is 5x more
expensive in `.xlsx` than row count suggests.** At 40 columns throughput drops to ~1,100
rows/sec, so 280,000 rows is ~4 minutes rather than the ~50 seconds a 7-column file takes.
For wide sheets, treat ~200,000 rows as the point where duration, not memory, is the reason
to split the file.

If you would rather not reason about column shape at all: **50,000 rows is safe for any
`.xlsx` shape on a 512MB budget**, and that is the number to quote when nobody has checked
the file.

### The worst legal `.xlsx`, because the format caps rows

`.xlsx` allows at most 1,048,576 rows per sheet (2^20), so unlike CSV there is a largest
possible file and the requirement can be stated absolutely rather than as a ceiling. At
1,048,575 data rows, projected from the measured 0.7MB per 1,000 rows per unique-text column:

| unique-text columns | peak RSS today | with a streaming shared-string reader |
|---|---|---|
| 1 | 0.9GB | 0.35GB |
| 3 | 2.3GB | 0.75GB |
| 6 | 4.4GB | 1.36GB |
| 10 | 7.3GB | 2.16GB |

So **importing any legal `.xlsx` needs ~2.3GB today** for a typical 3-text-column sheet, or
~4.4GB at six. A streaming reader (the 0.28 factor measured above) brings the same guarantee
down to **0.75GB and 1.36GB** - the difference between "needs a deliberately large container"
and "fits in an ordinary one".

Duration is not the binding constraint even at the format limit: 1,048,575 rows is ~3 minutes
at 7 columns, though ~16 minutes at 40.

**This is the question that decides whether streaming is worth building.** If every import
is a known file of known shape - the stated expectation, thousands of rows - the ceilings
above are irrelevant and the current implementation has orders of magnitude of headroom. If
this class ever has to accept an arbitrary user-supplied `.xlsx` without inspecting it
first, then the worst case is the requirement, and 2.3-4.4GB is a hard number to provision
against where 0.75-1.36GB is not.

### Would streaming the shared-string table help? Yes - 3.6x

Worth answering with a measurement rather than an assumption, because two very different
causes fit the same symptom: if the cost were the retained strings themselves, streaming
could not help at all, and only spilling to disk would. Same 72.2MB `sharedStrings.xml`,
1,500,007 strings, identical output, one fresh process each
(`benchmark/importer/shared_strings_probe.rb`):

| approach | peak RSS above baseline | time |
|---|---|---|
| `roo`, i.e. today | 1,003.6MB | 6.33s |
| plain `Nokogiri::XML.parse` | 942.2MB | 2.10s |
| `Nokogiri::XML::SAX::Parser` | **281.9MB** | 7.95s |

So the answer is the DOM, not the strings: **282MB of that 1,004MB is the strings a reader
genuinely has to keep; the other ~722MB is the tree built to extract them.** A SAX pass over
that one zip entry - the same lever already applied to `mergeCells` and to row/cell reading
(see FINDINGS.md) - removes it. Projected effect on the ceiling above, holding the retained
strings constant: **181,000 rows -> ~670,000 at 512MB**, and ~1.6M at 1GB.

The costs are real but small. SAX is ~3.8x slower on this entry (+5.9s), which is a one-time
cost per run - 7% on a 500,000-row import that already takes ~86 seconds. And it would mean
this class reading `sharedStrings.xml` itself rather than through `roo`, which is precisely
the trade already accepted for sheet rows: reuse `roo` for per-cell value typing, read the
raw XML directly where `roo`'s access pattern is the problem.

Two things found while measuring, worth recording:

- `roo` costs 61MB *more* than a plain DOM parse of the same entry, because
  `SharedStrings#fix_invalid_shared_strings` serialises the whole tree back to a String via
  `doc.to_s` just to test for one escape sequence (`_x000D_`), and re-parses the entire
  document if it matches - a second and potentially third full copy.
- Passing `disable_html_wrapper: true`, which this class already does, is load-bearing for
  memory and not only for output correctness: without it, `use_html?` triggers
  `extract_html`, a second full extraction cached separately in `@html`.

What this does **not** fix: the cost stays linear in distinct strings, ~0.19KB each. SAX
makes the constant 3.6x better; it does not make `.xlsx` bounded the way CSV is. Genuinely
bounding it would mean not holding the table at all - decompressing the entry to a temp file
and seeking by offset per lookup - because random access into a DEFLATE stream inside the
zip is not possible without decompressing from the start. That is a much larger change, and
these numbers do not argue for it yet.

## Reproducing

```bash
docker compose up -d db
docker compose exec rails-api bin/rails runner benchmark/importer/setup.rb
docker compose exec rails-api bash benchmark/importer/sweep.sh
docker compose exec rails-api bash benchmark/importer/sweep_xlsx.sh
docker compose exec rails-api bash -c 'cd benchmark/importer && ruby analyze.rb 512'
docker compose exec rails-api bash -c 'cd benchmark/importer && ruby analyze.rb 512 results_xlsx.jsonl'
```

`sweep.sh` runs 29 CSV points in ~45 minutes, most of it the `:activerecord` rows;
`sweep_xlsx.sh` runs 19 `.xlsx` points in ~20 minutes. `shared_strings_probe.rb <file>
roo|dom|sax` is the standalone DOM-versus-SAX comparison.
`analyze.rb` takes the memory budget in MB and reports the fitted slope and implied row
ceiling per mode, so re-deriving the table for a different container size needs no edits
here. `results.sample.jsonl` in that directory is the raw output this document was written
from, one JSON object per point.
