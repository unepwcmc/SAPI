# Base importer — changelog

Hand-maintained. Each release records the checksum of the tracked files, so a
client project can tell which version its copy is based on, and whether that
copy has been modified since.

Print the checksum of a copy:

```bash
ruby scripts/checksum.rb rails-api/app/services/importer
```

Check a copy against a release recorded below:

```bash
ruby scripts/checksum.rb rails-api/app/services/importer --verify CHANGELOG.md
```

That names the files that differ rather than just reporting a mismatch, and
exits non-zero on drift so it can gate CI. It compares against the newest
release by default; pass `--release 1.0.0` to check against an older one.
Add `--json` for machine-readable output.

The per-file tables below are what makes this work offline: a client can find
out *which* file drifted without needing a copy of the original to diff
against. They are emitted by `--files` and pasted in verbatim.

The checksum covers `base.rb`, `concerns/`, `logger.rb`, `row_transformer.rb`,
`parsers.rb`/`parsers/`, and `loaders.rb`/`loaders/` — see
[`importer.checksum.yml`](importer.checksum.yml) for the exact scope. It does
not cover the docs or this file. Application-specific example importers
(`post_*_importer.rb`) live outside this directory entirely, in
`app/services/importers/` (plural).

## 2.1.0 — 2026-09-04

`e50b970150b8e084972084e68342fcaebfd15aaa61141c9387cac383adc3d0bc` (19 files)

One data-corruption fix, one rename in `#logs`, and two smaller corrections. **The rename
is the only breaking change**: if you read the summary entry's `inserted:` key, it is now
`written:`. Everything else is a straight file replacement.

- **Bug fix**: an integer column now parses its value as decimal, always. `Integer()` was
  called without an explicit base, so Ruby applied its own literal prefix rules to the
  string: `"010"` became **8**, not 10 — silent corruption of exactly the kind this class's
  strict casting exists to prevent — while `"08"`/`"09"` raised as invalid octal despite
  being ordinary zero-padded decimals, and `"0x1F"`/`"0b11"` were silently accepted as 31
  and 3. Zero-padded numeric codes (reference numbers, country codes) are common in CSV and
  Excel exports. Now `Integer(value, 10)`: zero-padded values parse correctly, and
  hex/binary literals are rejected as an invalid integer like any other unparseable value.

  Present in every release since 1.0.0, so a copy vendored from any earlier version has it
  too and needs this fix applied there as well.

- **Breaking**: `#logs`' summary entry renames `inserted:` to `written:`, and each loader's
  own `write_batch` return value renames the same key. The old name was wrong for the
  insert-or-update modes: `raw_upsert_all` (and `activerecord`/`activerecord_import` with
  `unique_by` declared) counted every written row as an insert, so a run that updated 500
  existing rows reported `inserted: 500`. Since `#logs` is documented as safe to persist or
  render as-is, that number was being read as a create count. A bulk upsert doesn't report
  which rows conflicted, so inserts and updates genuinely can't be separated without a
  per-row cost — the key is now named for what it actually counts. See README.md.

- The reference example (`Importers::PostActiveRecordImporter`) now declares
  `unique_by :slug` and no longer maps the primary key. It previously declared
  `unique_by :id` with `'ID' => :id`, which means every row must already exist — and
  combined with its own `on_failure :skip`, a file of new rows imported **nothing** while
  still reporting success. A natural key exercises the same lookup path against a column
  you can seed from the same file, so following the README now gives a working first run.

- `:primary_key_value` is no longer resolved when nothing can read it. It is only ever
  readable from `after_batch`, so with that hook left as its default no-op the resolving
  query was one wasted `SELECT` per batch. `Importer::Base` now tells the loader whether
  the hook is overridden.

```
ff0f2709c2248e486b980bac9b147dfb154aeaf6e95c2cfeb3b7a7dce27eb808  base.rb
efe3074e11323e6551320d24e7681f1db2e092d45c58ef11dd22d24fd1dcf145  concerns/config.rb
18d3dd7e5ae26dda5f4c6223a9c921360b22fa3c8660d5c3885bbd169ebcca46  concerns/hooks.rb
d71ffa9c427207af7f36546cc2531b2d27f9f01de7d81856844af1429bf8293e  loaders.rb
9135fd7e7e308a18b73050c572c063ec60373c455a75c6b5f125e61e9a8172f6  loaders/activerecord_import.rb
e961bca5f957ed5adcbc0f2f158d0afe803ea60d7f53f4ec7e2e1db0ee25683c  loaders/base.rb
15a826a72d9c849f07e13825fc33fb81c3b4bf48c1ccf52892647c4cefd718cb  loaders/plain_record.rb
92316a95aac786b499955d02acd68c9ffb52da70d496868cf40147935211782c  loaders/raw_insert_all.rb
d57813098932080362e9e93aae65ed58d620350a1042a8591ea75d2cde67e53b  loaders/raw_upsert_all.rb
e48e73858389fdba39410ec012b9537ef5d2dce1c3d1e5c8d5ae266aaa68e648  loaders/row_isolatable.rb
4ae0914e9521047a3bf871fff1f0add00c9509f6887e595977853cdf712b2ef7  loaders/unique_by_config.rb
3acf4bc210ae459512bb6055ae5d9cf2bca8fc218d1201903a7260bb0aad6d0b  loaders/unique_by_resolver.rb
8c9319bc7a720c9592210ffe9bf5372275704be96bb9af9ad4461120c1dbb791  logger.rb
e76eed7c86ce19d15685271056434b0c54f5c9424e0a455ddf066831641655bc  parsers.rb
5545a9a80650f65f58dc439f43a6ea4bb23914fc7c665724201ff5ac215112e4  parsers/csv.rb
0710b66425bff25fd24734fa8d7897403f4b275774c76995aa2ab4d970d51b56  parsers/excel_x.rb
4a5f7069c1938bace2477da147e8433524373e4238d2d297c9520e3e94dd8ea3  parsers/excel_x/rich_text.rb
401822c335c73bb0107305dc71cbf0f0205744b21a1cbc7049843df9efcf30c0  parsers/excel_x/xml_namespace_agnostic.rb
33d4a9251f093745c1f80b828d876e2ad1ddb279711beebbd6fc95828859b812  row_transformer.rb
```

## 2.0.0 — 2026-08-27

`43247b329138e2ae3ed1208803f8f90c2b481ca88322a1848d7e384ca97ca3ea` (19 files)

Major bump for the internal restructuring below. The subclass-facing API is unchanged -
every existing subclass, config macro, and hook works exactly as before, and every
individual error message is byte-identical. One caveat to "no behavior change", config
time only: when a subclass has more than one config error, which one is reported first
may differ (detailed at the end). Upgrading is still a straight file replacement, but not
a small diff.

- **Composition instead of one mixin-heavy base class.** `Importer::Base` used to
  `include` every concern and every mode's write logic unconditionally, regardless of
  which a given subclass actually used. It now *has-a* parser (`Importer::Parsers::Csv`
  or `::ExcelX`) and a loader (one of `Importer::Loaders::RawInsertAll`,
  `::RawUpsertAll`, `::PlainRecord`, `::ActiverecordImport`), plus a standalone
  `Importer::RowTransformer` for the cast pipeline and `Importer::Logger` for `#logs` -
  each independently constructible and testable with no `Importer::Base` subclass
  involved at all. `concerns/casting.rb`, `concerns/validation.rb`,
  `concerns/primary_key_guard.rb`, `concerns/row_isolation.rb`,
  `concerns/unique_by_guard.rb`, `concerns/csv_parsing.rb`, `concerns/excel_parsing.rb`,
  `concerns/excel_rich_text.rb`, `concerns/xml_namespace_agnostic.rb`, and `modes/` are
  all gone, redistributed into the new structure (see `importer.checksum.yml`'s
  updated `include:` list, and FINDINGS.md for the full design writeup).
- `resync_primary_key_sequence!` renamed to `reset_pk_sequence!` - it only ever
  conditionally called Rails' own method of that name and did nothing else, so
  "resync" was a confusing verb for what it actually does.
- `node.name.split(':').last == 'row'` replaced with Nokogiri's own `node.local_name`.
- Inline comments across the engine trimmed to only the load-bearing ones - the
  detailed reasoning/evidence for every non-obvious decision already lives in
  FINDINGS.md and doesn't need to be duplicated inline too.
- **New**: `csv_encoding` for a `.csv`/`.tsv` source that isn't UTF-8 (e.g.
  `csv_encoding 'Windows-1252'`) - transcodes every row to UTF-8 on the way in.
  Deliberately narrower than a generic CSV-parser-options passthrough; see
  REQUIREMENTS.md. A malformed byte is rejected by `import!`'s own file validation,
  before the transaction opens and before any row is read - including under an explicit
  `csv_encoding 'utf-8'`, which validates identically to declaring no encoding at all
  (both are already UTF-8, so there is no transcode step that could raise on its own,
  and validity needs its own explicit check either way).
- `unique_by` now carries a matched partial index's own predicate, not just its
  columns - fixes `:activerecord` matching/updating a row outside the index's own
  scope, and `:activerecord_import` raising on the first real conflict against one.
- CSV line numbers now track the file's true physical line, including across `\r`,
  `\r\n`, and bare-CR row separators.
- `resolve_belongs_to` honours a `primary_key:` override on the reflection.
- `:activerecord` no longer collapses distinct source rows onto one record when a
  nullable `unique_by` column is blank.
- A failure while resyncing the primary-key sequence no longer makes `import!` raise
  for an import that already committed.
- Excel parsing no longer leaks file descriptors (carried forward from 1.0.2).
- **Ordering change**: when a subclass has more than one config error, which one is
  reported first may differ. `unique_by` resolution and `activerecord_import`'s two
  guards moved later (into the loader's constructor); `on_failure`, `csv_delimiter`/
  `csv_encoding` and `header_row`/`data_start_row` moved earlier. All still raise
  `ArgumentError` at config time, before any row is read, with unchanged messages.

```
6cdc613fa4e7ae309813f437778b7bb665e447e21e66af3d7fc54c6cdc1087bb  base.rb
efe3074e11323e6551320d24e7681f1db2e092d45c58ef11dd22d24fd1dcf145  concerns/config.rb
18d3dd7e5ae26dda5f4c6223a9c921360b22fa3c8660d5c3885bbd169ebcca46  concerns/hooks.rb
d71ffa9c427207af7f36546cc2531b2d27f9f01de7d81856844af1429bf8293e  loaders.rb
b9b9e975008d7218838821f80de7cfef9bcb957ce4082c5bf98a23f8d1ddc278  loaders/activerecord_import.rb
d347a44aed2959340d1a576838c82b6657af1f8a62a016d20d3b2637a92b634d  loaders/base.rb
5993ac75facd31402f2eaf5b39c5a932b14fdfad7357815eb0c693490ca71f36  loaders/plain_record.rb
019a016aad3ce8cf53f52b503c9b206e9063274089ebfbdbcf7092e1035e9645  loaders/raw_insert_all.rb
511dd4a00f39a358bd3e2a61186d9e667818cf8ce70810a1f3e4ba07be2148e8  loaders/raw_upsert_all.rb
e48e73858389fdba39410ec012b9537ef5d2dce1c3d1e5c8d5ae266aaa68e648  loaders/row_isolatable.rb
4ae0914e9521047a3bf871fff1f0add00c9509f6887e595977853cdf712b2ef7  loaders/unique_by_config.rb
3acf4bc210ae459512bb6055ae5d9cf2bca8fc218d1201903a7260bb0aad6d0b  loaders/unique_by_resolver.rb
24f6d141511fde01d3cc2d7b4a9ccfc7f97b5c84c3a7cce5fa1aec1f58108efa  logger.rb
e76eed7c86ce19d15685271056434b0c54f5c9424e0a455ddf066831641655bc  parsers.rb
5545a9a80650f65f58dc439f43a6ea4bb23914fc7c665724201ff5ac215112e4  parsers/csv.rb
0710b66425bff25fd24734fa8d7897403f4b275774c76995aa2ab4d970d51b56  parsers/excel_x.rb
4a5f7069c1938bace2477da147e8433524373e4238d2d297c9520e3e94dd8ea3  parsers/excel_x/rich_text.rb
401822c335c73bb0107305dc71cbf0f0205744b21a1cbc7049843df9efcf30c0  parsers/excel_x/xml_namespace_agnostic.rb
4a2a5bb3223fe606294b7d8446b970b7064720e8043399d1c4aff27732c3f78e  row_transformer.rb
```

## 1.0.2 — 2026-08-18

`01b5bac1f5e5ca7233c380cf2e3d65b4ce0400c94c3f25c9e2ed88f0089c209b` (17 files)

One bug fix; no API changes. Upgrading is a straight file replacement.

- Excel parsing no longer leaks file descriptors. `Nokogiri::XML::Reader`
  retains the IO it is given and never closes it, so every import leaked two
  handles for the sheet XML — one from reading the header, one from the
  streaming row pass. Both now use `File.open`'s block form, which closes in
  its own `ensure` however the block exits, including the early `break` the
  header read always does.

```
f46057ca9a271d224bd6bd4eb0096574189c81d0e8f6c1b72d740b74bc7dfe9b  base.rb
6751b1eef516387853302b209c0bc42d6e3663835bd8a3dc9ff7e7a520d89caa  concerns/casting.rb
05430820a96c7568a3c692ff08a0c2532b2d0e97b549d85fb5c6b2d2f5df6c64  concerns/config.rb
8598949d0e6a5c72711008e84559efd1a2904fd7f1a98f233103ff0e7a2e15f1  concerns/csv_parsing.rb
8e516d6898bf912e50cbf6b60d85dde9942bd13b45ced3a7c7dee0bd8b90925f  concerns/excel_parsing.rb
4896e7e0e4363432ff8898807919bcff3212df493badb167938dda7df4e03f79  concerns/excel_rich_text.rb
87e6831a00e9d5f12260173eed0de70a776860ab2c166f7d38217549bd1f584b  concerns/hooks.rb
a7e0256b1d2a9ab43208d0d328845c70d0572a0a1adc6f5da857c7b04e6ca554  concerns/logging.rb
227bcd4cc9d439e44cb9788bf05825523a76016efafdb68dfa4adbcfb3877efb  concerns/primary_key_guard.rb
c1a119299aaba70b5560fc53d780a32daf7c9b039764a09f4c4da04d4f753eb8  concerns/row_isolation.rb
12fa981e39cb8aeede784586acd3b1a31cd71af84d3ffb2f16a50d79d0310759  concerns/unique_by_guard.rb
f4d7d5153d4d1583039af9cfc842ffa7481a2464b0b5623cd5512de18303b069  concerns/validation.rb
d119a4d0be0ad7288f5ba6025c3d2c785d65963ac39a8f61ec984d89863ea6e5  concerns/xml_namespace_agnostic.rb
782b4ce0691794f10fc6808724718ac1d46b069460ba9473607e38a45ad49c86  modes/activerecord_import.rb
2e42d637500dbfe5407b98c8eec42d98204d2f3c5cf58ed0b53ff36bf2c5fd67  modes/plain_record.rb
5e079b3b1ac6b686d9df26a0e8dffd1ae2f1c5709e3f33e7e6d395f0decf4ac6  modes/raw_insert_all.rb
2a7b49454af7eafa44a297d39efddb031174a79830e2dde2b686c28fb4feb6fe  modes/raw_upsert_all.rb
```

## 1.0.1 — 2026-08-18

`2e42ce53d5f81f5f4fc710f6f108f734deea335e1b5e5ce498a9588e479a1fd2` (17 files)

Bug fixes only; no API changes. Upgrading is a straight file replacement.

- `unique_by` now carries a matched partial index's own predicate, not just
  its columns. `:activerecord` scopes its lookup by the predicate instead of
  matching a row the index never covered, and `:activerecord_import` passes it
  as `index_predicate:` rather than raising "no unique or exclusion constraint
  matching the ON CONFLICT specification" on the first real conflict.
- CSV line numbers now track the file's true physical line. The counter was
  per-record, so every reported line drifted after the first quoted field
  containing an embedded line break — which RFC 4180 allows.
- `resolve_belongs_to` honours a `primary_key:` override on the reflection
  instead of always using `id`.
- `:activerecord` no longer collapses distinct source rows onto one record
  when a nullable `unique_by` column is blank; it skips the lookup under an
  ordinary nulls-distinct index.
- A failure while resyncing the primary-key sequence no longer makes `import!`
  raise for an import that already committed, which invited an unsafe retry.

```
f46057ca9a271d224bd6bd4eb0096574189c81d0e8f6c1b72d740b74bc7dfe9b  base.rb
6751b1eef516387853302b209c0bc42d6e3663835bd8a3dc9ff7e7a520d89caa  concerns/casting.rb
05430820a96c7568a3c692ff08a0c2532b2d0e97b549d85fb5c6b2d2f5df6c64  concerns/config.rb
8598949d0e6a5c72711008e84559efd1a2904fd7f1a98f233103ff0e7a2e15f1  concerns/csv_parsing.rb
bdabaff6ae75c904c4ac4cde54fa7981f3f5301c28d1b262d6e65c44bfe42c06  concerns/excel_parsing.rb
4896e7e0e4363432ff8898807919bcff3212df493badb167938dda7df4e03f79  concerns/excel_rich_text.rb
87e6831a00e9d5f12260173eed0de70a776860ab2c166f7d38217549bd1f584b  concerns/hooks.rb
a7e0256b1d2a9ab43208d0d328845c70d0572a0a1adc6f5da857c7b04e6ca554  concerns/logging.rb
227bcd4cc9d439e44cb9788bf05825523a76016efafdb68dfa4adbcfb3877efb  concerns/primary_key_guard.rb
c1a119299aaba70b5560fc53d780a32daf7c9b039764a09f4c4da04d4f753eb8  concerns/row_isolation.rb
12fa981e39cb8aeede784586acd3b1a31cd71af84d3ffb2f16a50d79d0310759  concerns/unique_by_guard.rb
f4d7d5153d4d1583039af9cfc842ffa7481a2464b0b5623cd5512de18303b069  concerns/validation.rb
d119a4d0be0ad7288f5ba6025c3d2c785d65963ac39a8f61ec984d89863ea6e5  concerns/xml_namespace_agnostic.rb
782b4ce0691794f10fc6808724718ac1d46b069460ba9473607e38a45ad49c86  modes/activerecord_import.rb
2e42d637500dbfe5407b98c8eec42d98204d2f3c5cf58ed0b53ff36bf2c5fd67  modes/plain_record.rb
5e079b3b1ac6b686d9df26a0e8dffd1ae2f1c5709e3f33e7e6d395f0decf4ac6  modes/raw_insert_all.rb
2a7b49454af7eafa44a297d39efddb031174a79830e2dde2b686c28fb4feb6fe  modes/raw_upsert_all.rb
```

## 1.0.0 — 2026-08-18

`b0a76e5330c41596b272c872fe849ff054bb7b1f7fcd61eb9dd27917d645236b` (17 files)

First versioned release. Baseline capabilities:

- Four write modes: plain ActiveRecord, `activerecord-import`, raw `insert_all`
  and raw `upsert_all`.
- CSV and Excel parsing, with Excel rows and cells read via streaming XML
  rather than Roo's eager row access.
- Lifecycle hooks (`on_row_skip`, `before_batch`, `after_batch`), with each
  row's raw values carried into the batch hooks.
- `derived_attributes` for attributes with no source column, and
  `resolve_belongs_to` for a foreign key given as a natural key.
- Row isolation, validation, casting, and primary-key and `unique_by` guards.
- `skip_file_validation` for importers sharing one `file_path`.

```
69e8ad2b585e2cecfb5fc5efc70b9278603445fdc17591b959fa0460369f4945  base.rb
daf400dff877c269f17cf0d708d2cc364e0721be1473c8057d2cb0673d290f67  concerns/casting.rb
05430820a96c7568a3c692ff08a0c2532b2d0e97b549d85fb5c6b2d2f5df6c64  concerns/config.rb
90a0032bb2180894a75bd3f4d05231843e5da169b39f94e06b231d4b518e3fc3  concerns/csv_parsing.rb
bdabaff6ae75c904c4ac4cde54fa7981f3f5301c28d1b262d6e65c44bfe42c06  concerns/excel_parsing.rb
4896e7e0e4363432ff8898807919bcff3212df493badb167938dda7df4e03f79  concerns/excel_rich_text.rb
87e6831a00e9d5f12260173eed0de70a776860ab2c166f7d38217549bd1f584b  concerns/hooks.rb
54e43b4cf118e9d5249a27b765cbb91dc7dea6befa59243e339c29c2653ea18d  concerns/logging.rb
227bcd4cc9d439e44cb9788bf05825523a76016efafdb68dfa4adbcfb3877efb  concerns/primary_key_guard.rb
c1a119299aaba70b5560fc53d780a32daf7c9b039764a09f4c4da04d4f753eb8  concerns/row_isolation.rb
12fa981e39cb8aeede784586acd3b1a31cd71af84d3ffb2f16a50d79d0310759  concerns/unique_by_guard.rb
a1ab5a8e06006f87ca8c96ee207165734423f38b5ad2915f69c36aa7dd5fde0b  concerns/validation.rb
d119a4d0be0ad7288f5ba6025c3d2c785d65963ac39a8f61ec984d89863ea6e5  concerns/xml_namespace_agnostic.rb
ab6aeefe53283944a7732472e13a32c2afbcbb2df780c2985e602cb58db9143e  modes/activerecord_import.rb
4c9b3faff635eda5c24e703005e1b4138f3306e03afb69bedab2876b8f40c122  modes/plain_record.rb
5e079b3b1ac6b686d9df26a0e8dffd1ae2f1c5709e3f33e7e6d395f0decf4ac6  modes/raw_insert_all.rb
2a7b49454af7eafa44a297d39efddb031174a79830e2dde2b686c28fb4feb6fe  modes/raw_upsert_all.rb
```
