require 'spec_helper'
require 'tempfile'

# Importer::Concerns::Hooks' subclass-overridable hooks other than exclude_row? (which
# already has its own coverage split across base_spec.rb/base_excel_parsing_spec.rb) -
# on_row_skip, before_batch, after_batch. Its own file rather than growing either of
# those further, given as its own scratch table (only what these hooks need: a `name`
# presence validation to trigger an :activerecord/:activerecord_import skip, nothing
# else base_spec.rb's own wider table already covers).
RSpec.describe Importer::Base do
  # rubocop:disable RSpec/BeforeAfterAll -- table DDL, not row data; nothing here needs a per-example rollback
  before(:context) do
    ActiveRecord::Base.connection.create_table :importer_hooks_spec_widgets, force: true do |t|
      t.string :name
      t.integer :quantity
    end
    ActiveRecord::Base.connection.add_index :importer_hooks_spec_widgets, :name, unique: true
  end

  after(:context) do
    ActiveRecord::Base.connection.drop_table :importer_hooks_spec_widgets, if_exists: true
  end
  # rubocop:enable RSpec/BeforeAfterAll

  let(:widget_class) do
    Class.new(ApplicationRecord) do
      self.table_name = 'importer_hooks_spec_widgets'
      validates :name, presence: true
    end
  end

  before do
    stub_const('ImporterHooksSpecWidget', widget_class)
  end

  def write_csv(content)
    file = Tempfile.new([ 'import', '.csv' ])
    file.binmode
    file.write(content)
    file.close
    file
  end

  def raw_importer_class(&block)
    Class.new(described_class) do
      target_model ImporterHooksSpecWidget
      mode :raw_insert_all
      required_headers({ 'Name' => :name, 'Quantity' => :quantity })
      class_eval(&block) if block
    end
  end

  def activerecord_importer_class(&block)
    Class.new(described_class) do
      target_model ImporterHooksSpecWidget
      mode :activerecord
      required_headers({ 'Name' => :name, 'Quantity' => :quantity })
      class_eval(&block) if block
    end
  end

  def activerecord_import_importer_class(&block)
    Class.new(described_class) do
      target_model ImporterHooksSpecWidget
      mode :activerecord_import
      required_headers({ 'Name' => :name, 'Quantity' => :quantity })
      class_eval(&block) if block
    end
  end

  def upsert_importer_class(&block)
    Class.new(described_class) do
      target_model ImporterHooksSpecWidget
      mode :raw_upsert_all
      unique_by :name
      required_headers({ 'Name' => :name, 'Quantity' => :quantity })
      class_eval(&block) if block
    end
  end

  describe 'on_row_skip' do
    it 'is called with the skipped row\'s line_number/attrs/message under :activerecord mode' do
      calls = []
      klass =
        activerecord_importer_class do
          on_failure :skip
          define_method(:on_row_skip) { |line_number:, attrs:, message:| calls << { line_number:, attrs:, message: } }
        end

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,10
        ,3
        Widget C,7
      CSV

      klass.new(file_path: csv.path).import!

      expect(calls).to eq(
        [ { line_number: 3, attrs: { name: nil, quantity: 3 }, message: "Name can't be blank" } ]
      )
    end

    it 'is called with the skipped row\'s line_number/attrs/message under :activerecord_import mode' do
      calls = []
      klass =
        activerecord_import_importer_class do
          on_failure :skip
          define_method(:on_row_skip) { |line_number:, attrs:, message:| calls << { line_number:, attrs:, message: } }
        end

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,10
        ,3
        Widget C,7
      CSV

      klass.new(file_path: csv.path).import!

      expect(calls).to eq(
        [ { line_number: 3, attrs: { name: nil, quantity: 3 }, message: "Name can't be blank" } ]
      )
    end

    it 'is not called under the default on_failure :rollback - that raises before ever reaching a skip decision' do
      calls = []
      klass =
        activerecord_importer_class do
          define_method(:on_row_skip) { |**args| calls << args }
        end

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,10
        ,3
      CSV

      expect { klass.new(file_path: csv.path).import! }.to raise_error(described_class::ImportError)
      expect(calls).to be_empty
    end

    it 'is called for a primary-key-protection drop (reject_missing_primary_key_rows!), not just a validation ' \
       'failure, under :activerecord_import' do
      # Regression: found by an external review, confirmed by reproducing it directly -
      # reject_missing_primary_key_rows! (Importer::Loaders::Base) is a third
      # skip path, distinct from a validation failure - it already logged and incremented
      # @skipped_count under on_failure :skip, but never called on_row_skip at all, so a
      # subclass tracking skips via the hook silently missed exactly this category, in
      # this mode specifically (the equivalent :activerecord path, in
      # loaders/plain_record.rb, already called on_row_skip correctly via
      # handle_row_failure - only this mode's own separate code path had the gap).
      calls = []
      klass =
        activerecord_import_importer_class do
          unique_by :id
          on_failure :skip
          required_headers({ 'Id' => :id, 'Name' => :name, 'Quantity' => :quantity })
          define_method(:on_row_skip) { |line_number:, attrs:, message:| calls << { line_number:, attrs:, message: } }
        end

      csv = write_csv(<<~CSV)
        Id,Name,Quantity
        999,Nonexistent,5
      CSV

      klass.new(file_path: csv.path).import!

      expect(calls).to eq(
        [
          {
            line_number: 2,
            attrs: { id: 999, name: 'Nonexistent', quantity: 5 },
            message: "no existing ImporterHooksSpecWidget found for id: 999, and allow_primary_key_write is false"
          }
        ]
      )
    end

    it 'rolls back the whole run when a subclass override raises, the same as any other in-batch failure' do
      klass =
        activerecord_importer_class do
          on_failure :skip
          define_method(:on_row_skip) { |**| raise 'boom from on_row_skip' }
        end

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,10
        ,3
      CSV

      expect { klass.new(file_path: csv.path).import! }.to raise_error('boom from on_row_skip')
      expect(ImporterHooksSpecWidget.count).to eq(0)
    end
  end

  describe 'before_batch/after_batch' do
    it 'is called once per non-empty batch, with that batch\'s rows, for both hooks' do
      before_batches = []
      after_batches = []
      klass =
        raw_importer_class do
          batch_size 2
          define_method(:before_batch) { |batch| before_batches << batch.pluck(:attrs) }
          define_method(:after_batch) { |batch| after_batches << batch.pluck(:attrs) }
        end

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
        Widget B,2
        Widget C,3
      CSV

      klass.new(file_path: csv.path).import!

      expect(before_batches).to eq(
        [
          [ { name: 'Widget A', quantity: 1 }, { name: 'Widget B', quantity: 2 } ],
          [ { name: 'Widget C', quantity: 3 } ]
        ]
      )
      expect(after_batches).to eq(before_batches)
    end

    # The reason to look at a row again after it has been written is a column required_headers
    # does not map - so :row has to carry the whole row, not just the mapped columns :attrs
    # already holds.
    it 'carries the raw row on each item, including columns required_headers does not map' do
      rows = []
      klass = raw_importer_class { define_method(:after_batch) { |batch| rows.concat(batch.pluck(:row)) } }

      csv = write_csv(<<~CSV)
        Name,Quantity,Tags
        Widget A,1,"red, blue"
      CSV

      klass.new(file_path: csv.path).import!

      expect(rows).to eq([ { 'Name' => 'Widget A', 'Quantity' => '1', 'Tags' => 'red, blue' } ])
    end

    it 'does not fire for a phantom empty trailing batch when the row count divides evenly by batch_size' do
      before_batches = []
      klass =
        raw_importer_class do
          batch_size 2
          define_method(:before_batch) { |batch| before_batches << batch }
        end

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
        Widget B,2
      CSV

      klass.new(file_path: csv.path).import!

      expect(before_batches.size).to eq(1)
    end

    it 'rolls back the whole run when before_batch raises' do
      klass = raw_importer_class { define_method(:before_batch) { |_batch| raise 'boom from before_batch' } }

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
      CSV

      expect { klass.new(file_path: csv.path).import! }.to raise_error('boom from before_batch')
      expect(ImporterHooksSpecWidget.count).to eq(0)
    end

    it 'rolls back the whole run when after_batch raises' do
      klass = raw_importer_class { define_method(:after_batch) { |_batch| raise 'boom from after_batch' } }

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
      CSV

      expect { klass.new(file_path: csv.path).import! }.to raise_error('boom from after_batch')
      expect(ImporterHooksSpecWidget.count).to eq(0)
    end
  end

  describe 'transaction connection' do
    # Regression: found by an external review, confirmed by reproducing it directly
    # against this app's real Wordpress::Record-style (mysql2) connection - every
    # transaction in this class used to open on ActiveRecord::Base's own connection,
    # not target_model's, so for a target_model on any other connection (this app's
    # own Wordpress::Record, or equally a second Postgres database - not
    # adapter-specific) an exception after a successful write left the row committed
    # anyway, since the actual write never ran inside a transaction on its own
    # connection at all. This spec suite only has one real connection configured for
    # the test environment, so it can't reproduce the cross-connection symptom
    # end-to-end here (that reproduction lives in FINDINGS.md) - what it can and does
    # pin down is the fix itself: every transaction opens on target_model's own
    # connection, by name, not on ActiveRecord::Base's.
    #
    # Asserts an exact call count, not at_least(:once) - found by a second external
    # review, confirmed by reproducing it directly: at_least(:once) still passes even
    # if a specific inner call site (loaders/row_isolatable.rb, loaders/
    # activerecord_import.rb, loaders/plain_record.rb) is reverted back to
    # ActiveRecord::Base.transaction, since base.rb's own outer transaction call alone
    # already satisfies it - a real regression at any inner call site would go
    # undetected. A 1-row CSV always produces exactly 2 target_model.transaction calls
    # for any of these modes: base.rb's own outer one (wraps the whole run) plus
    # exactly one inner one (the mode-specific per-batch or per-row write) - reverting
    # either call site changes this count and fails the spec.
    it 'opens on target_model\'s own connection, not ActiveRecord::Base\'s, for the whole run' do
      allow(ImporterHooksSpecWidget).to receive(:transaction).and_call_original

      klass = raw_importer_class

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterHooksSpecWidget).to have_received(:transaction).with(requires_new: true).exactly(2).times
    end

    it 'opens on target_model\'s own connection for a per-batch write (raw_* modes)' do
      allow(ImporterHooksSpecWidget).to receive(:transaction).and_call_original

      klass = upsert_importer_class

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterHooksSpecWidget).to have_received(:transaction).with(requires_new: true).exactly(2).times
    end

    it 'opens on target_model\'s own connection for a per-batch write (:activerecord_import)' do
      allow(ImporterHooksSpecWidget).to receive(:transaction).and_call_original

      klass = activerecord_import_importer_class

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterHooksSpecWidget).to have_received(:transaction).with(requires_new: true).exactly(2).times
    end

    it 'opens on target_model\'s own connection for a per-row save (:activerecord)' do
      allow(ImporterHooksSpecWidget).to receive(:transaction).and_call_original

      klass = activerecord_importer_class

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterHooksSpecWidget).to have_received(:transaction).with(requires_new: true).exactly(2).times
    end

    it 'opens on target_model\'s own connection during the row-by-row retry path too (isolate_failing_rows)' do
      # The one call site the 4 specs above don't reach at all: isolate_failing_rows
      # (loaders/row_isolatable.rb) only runs after the initial bulk attempt hits a
      # genuine DB-level failure (here, two rows sharing importer_hooks_spec_widgets'
      # own unique index on :name) - retrying each row individually to identify which
      # one(s) are bad, before the whole run re-raises and rolls back regardless (raw_*
      # modes never survive a batch failure, on_failure is always :rollback there).
      # 4 calls expected: the outer run (1) + the initial whole-batch attempt (1,
      # fails) + one retry per row in that batch (2).
      allow(ImporterHooksSpecWidget).to receive(:transaction).and_call_original

      klass = raw_importer_class

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
        Widget A,2
      CSV

      expect { klass.new(file_path: csv.path).import! }.to raise_error(described_class::ImportError)

      expect(ImporterHooksSpecWidget).to have_received(:transaction).with(requires_new: true).exactly(4).times
    end
  end

  describe 'primary_key_value on after_batch\'s items' do
    it 'is the newly-inserted row\'s real id under :raw_insert_all, when unique_by is declared' do
      # raw_insert_all never requires unique_by (it's an always-insert mode, no conflict
      # target), but declaring one anyway gives resolve_primary_key_values! a natural
      # key to resolve by value - see the "no unique_by, no explicit PK" example below
      # for what happens without one.
      pks = []
      klass =
        raw_importer_class do
          unique_by :name
          define_method(:after_batch) { |batch| pks.concat(batch.pluck(:primary_key_value)) }
        end

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
      CSV

      klass.new(file_path: csv.path).import!

      expect(pks).to eq([ ImporterHooksSpecWidget.find_by(name: 'Widget A').id ])
    end

    # :primary_key_value is only readable from after_batch, so with the no-op stub still
    # in place resolving it costs a SELECT per batch for a value nothing can read.
    it 'skips the resolving SELECT entirely when after_batch is not overridden' do
      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
      CSV

      # Counts only assign_primary_key_values_by_unique_key!'s own query - a pluck of the
      # unique_by column plus the primary key, filtered by that column. Matching this
      # shape rather than every SELECT keeps schema-cache warm-up out of the count, which
      # otherwise lands entirely on whichever importer runs first.
      count_resolves =
        lambda do |klass|
               ImporterHooksSpecWidget.delete_all
               count = 0
               subscriber =
                 ActiveSupport::Notifications.subscribe('sql.active_record') do |_n, _s, _f, _i, payload|
                   sql = payload[:sql]
                   count += 1 if sql.start_with?('SELECT') && sql.include?('"name"') && sql.include?('"id"') && sql.include?('WHERE')
                 end

               begin
                 klass.new(file_path: csv.path).import!
               ensure
                 ActiveSupport::Notifications.unsubscribe(subscriber)
               end

               count
        end

      with_hook =
        count_resolves.call(
          raw_importer_class do
            unique_by :name
            define_method(:after_batch) { |batch| batch }
          end
        )

      without_hook = count_resolves.call(raw_importer_class { unique_by :name })

      expect(with_hook).to eq(1)
      expect(without_hook).to eq(0)
    end

    it 'is never set for :raw_insert_all with no unique_by declared and no explicit primary key provided' do
      # Regression for the fix that replaced RETURNING-row-order matching with
      # value-based resolution (see FINDINGS.md): a "blind" bulk insert with nothing to
      # reliably correlate a row to its generated id by - this is a deliberate
      # narrowing, not an oversight. Before the fix, this case "worked" via Postgres
      # RETURNING's row order matching input order - an undocumented, unverifiable
      # assumption an external review confirmed is not something to rely on.
      batches = []
      klass = raw_importer_class { define_method(:after_batch) { |batch| batches << batch } }

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterHooksSpecWidget.count).to eq(1)
      expect(batches.first.first).not_to have_key(:primary_key_value)
    end

    it 'leaves :primary_key_value unset for rows sharing a null unique_by value, but resolves the rest normally' do
      # unique_by's underlying unique index allows nulls (Postgres's default, "nulls
      # distinct" - confirmed via the widgets table's own index, added with no
      # nulls_not_distinct option) - so more than one row in the same batch can
      # legitimately share a null value. assign_primary_key_values_by_unique_key! can't
      # tell which generated id belongs to which of those rows, so neither gets
      # :primary_key_value - everything else in the same batch still resolves.
      batches = []
      klass =
        raw_importer_class do
          unique_by :name
          define_method(:after_batch) { |batch| batches << batch }
        end

      csv = write_csv(<<~CSV)
        Name,Quantity
        ,1
        ,2
        Widget C,3
      CSV

      klass.new(file_path: csv.path).import!

      batch = batches.first
      blank_name_items = batch.select { |item| item[:attrs][:name].nil? }
      named_item = batch.find { |item| item[:attrs][:name] == 'Widget C' }

      expect(blank_name_items.size).to eq(2)
      expect(blank_name_items.map { |item| item.key?(:primary_key_value) }).to eq([ false, false ])
      expect(named_item[:primary_key_value]).to eq(ImporterHooksSpecWidget.find_by(name: 'Widget C').id)
    end

    it 'is the newly-inserted row\'s real id under :raw_upsert_all, when the row does not already exist' do
      pks = []
      klass = upsert_importer_class { define_method(:after_batch) { |batch| pks.concat(batch.pluck(:primary_key_value)) } }

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
      CSV

      klass.new(file_path: csv.path).import!

      expect(pks).to eq([ ImporterHooksSpecWidget.find_by(name: 'Widget A').id ])
    end

    it 'is the existing record\'s own id, not a new one, under :raw_upsert_all when the row updates via unique_by' do
      existing = ImporterHooksSpecWidget.create!(name: 'Widget A', quantity: 1)
      pks = []
      klass = upsert_importer_class { define_method(:after_batch) { |batch| pks.concat(batch.pluck(:primary_key_value)) } }

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,99
      CSV

      klass.new(file_path: csv.path).import!

      expect(pks).to eq([ existing.id ])
      expect(ImporterHooksSpecWidget.count).to eq(1)
      expect(existing.reload.quantity).to eq(99)
    end

    it 'is the existing record\'s own id, not a stale caller-supplied one, under :raw_upsert_all when ' \
       'unique_by conflicts on a non-primary-key column and the row also supplies a primary key' do
      # Regression: found by an external review, confirmed by reproducing it directly.
      # Rails' upsert_all excludes the primary key from its own DO UPDATE SET when the
      # conflict target is some other natural key (unique_by :name here, not :id) - so
      # a conflicting row's caller-supplied id is never actually written, and step 1's
      # "trust attrs[pk] directly" would have reported it anyway. Reproduced: existing
      # row id 1, CSV row supplying id 99999 for the same name - the row stayed id 1
      # (every other column still updated correctly), but the old code reported 99999.
      existing = ImporterHooksSpecWidget.create!(name: 'Widget A', quantity: 1)
      pks = []
      klass =
        upsert_importer_class do
          allow_primary_key_write true
          required_headers({ 'Id' => :id, 'Name' => :name, 'Quantity' => :quantity })
          define_method(:after_batch) { |batch| pks.concat(batch.pluck(:primary_key_value)) }
        end

      csv = write_csv(<<~CSV)
        Id,Name,Quantity
        99999,Widget A,99
      CSV

      klass.new(file_path: csv.path).import!

      expect(pks).to eq([ existing.id ])
      expect(ImporterHooksSpecWidget.count).to eq(1)
      expect(existing.reload.quantity).to eq(99)
    end

    it 'is the newly-inserted row\'s real id under :activerecord' do
      pks = []
      klass = activerecord_importer_class { define_method(:after_batch) { |batch| pks.concat(batch.pluck(:primary_key_value)) } }

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
      CSV

      klass.new(file_path: csv.path).import!

      expect(pks).to eq([ ImporterHooksSpecWidget.find_by(name: 'Widget A').id ])
    end

    it 'is the existing record\'s own id, not a new one, under :activerecord when the row updates via unique_by' do
      existing = ImporterHooksSpecWidget.create!(name: 'Widget A', quantity: 1)
      pks = []
      klass =
        activerecord_importer_class do
          unique_by :name
          define_method(:after_batch) { |batch| pks.concat(batch.pluck(:primary_key_value)) }
        end

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,99
      CSV

      klass.new(file_path: csv.path).import!

      expect(pks).to eq([ existing.id ])
      expect(ImporterHooksSpecWidget.count).to eq(1)
    end

    it 'is the newly-inserted row\'s real id under :activerecord_import, when unique_by is declared' do
      # activerecord_import's own PK backfill (records[i].id after Model.import) relies
      # on the same positional-RETURNING assumption this fix moved away from - see
      # written_batch_items in loaders/activerecord_import.rb - so unique_by is what makes
      # this resolvable now, the same as raw_insert_all/raw_upsert_all.
      pks = []
      klass =
        activerecord_import_importer_class do
          unique_by :name
          define_method(:after_batch) { |batch| pks.concat(batch.pluck(:primary_key_value)) }
        end

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
      CSV

      klass.new(file_path: csv.path).import!

      expect(pks).to eq([ ImporterHooksSpecWidget.find_by(name: 'Widget A').id ])
    end

    it 'is never set for :activerecord_import with no unique_by declared and no explicit primary key provided' do
      batches = []
      klass = activerecord_import_importer_class { define_method(:after_batch) { |batch| batches << batch } }

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterHooksSpecWidget.count).to eq(1)
      expect(batches.first.first).not_to have_key(:primary_key_value)
    end

    it 'is the existing record\'s own id, not a new one, under :activerecord_import when the row updates via unique_by' do
      existing = ImporterHooksSpecWidget.create!(name: 'Widget A', quantity: 1)
      pks = []
      klass =
        activerecord_import_importer_class do
          unique_by :name
          define_method(:after_batch) { |batch| pks.concat(batch.pluck(:primary_key_value)) }
        end

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,99
      CSV

      klass.new(file_path: csv.path).import!

      expect(pks).to eq([ existing.id ])
      expect(ImporterHooksSpecWidget.count).to eq(1)
    end

    it 'is set only for the written row, and absent for the skipped one, in the same mixed batch under :activerecord' do
      batches = []
      klass =
        activerecord_importer_class do
          on_failure :skip
          define_method(:after_batch) { |batch| batches << batch }
        end

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
        ,2
      CSV

      klass.new(file_path: csv.path).import!

      batch = batches.first
      written = batch.find { |item| item[:line_number] == 2 }
      skipped = batch.find { |item| item[:line_number] == 3 }

      expect(written[:primary_key_value]).to eq(ImporterHooksSpecWidget.find_by(name: 'Widget A').id)
      expect(skipped).not_to have_key(:primary_key_value)
    end

    it 'is set only for the written row, and absent for the skipped one, in the same mixed batch under :activerecord_import' do
      batches = []
      klass =
        activerecord_import_importer_class do
          unique_by :name
          on_failure :skip
          define_method(:after_batch) { |batch| batches << batch }
        end

      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
        ,2
      CSV

      klass.new(file_path: csv.path).import!

      batch = batches.first
      written = batch.find { |item| item[:line_number] == 2 }
      skipped = batch.find { |item| item[:line_number] == 3 }

      expect(written[:primary_key_value]).to eq(ImporterHooksSpecWidget.find_by(name: 'Widget A').id)
      expect(skipped).not_to have_key(:primary_key_value)
    end
  end

  describe 'primary key sequence resync after allow_primary_key_write' do
    it 'prevents a later plain create! from colliding with a manually-inserted id - the actual bug this guards against' do
      # Regression: writing an explicit id via allow_primary_key_write never advances
      # Postgres' own underlying sequence (insert_all!/upsert_all/save! all bypass
      # nextval() whenever a value is supplied directly) - reproduced directly before
      # this guard existed: importing an explicit id sitting exactly where the sequence
      # was about to land next left a later, unrelated plain create! raising
      # PG::UniqueViolation ("already exists"), since nextval() produced the same id
      # this import had already claimed manually.
      2.times { |n| ImporterHooksSpecWidget.create!(name: "Existing #{n}", quantity: 0) }
      next_sequence_id = ImporterHooksSpecWidget.maximum(:id) + 1

      klass =
        raw_importer_class do
          allow_primary_key_write true
          required_headers({ 'Id' => :id, 'Name' => :name, 'Quantity' => :quantity })
        end

      csv = write_csv(<<~CSV)
        Id,Name,Quantity
        #{next_sequence_id},Manually Inserted,1
      CSV

      klass.new(file_path: csv.path).import!

      expect { ImporterHooksSpecWidget.create!(name: 'Should Not Collide', quantity: 2) }.not_to raise_error
    end

    it 'does not touch the sequence at all when allow_primary_key_write is false (the default)' do
      klass = raw_importer_class
      csv = write_csv(<<~CSV)
        Name,Quantity
        Widget A,1
      CSV
      allow(ImporterHooksSpecWidget.connection).to receive(:reset_pk_sequence!)

      klass.new(file_path: csv.path).import!

      expect(ImporterHooksSpecWidget.connection).not_to have_received(:reset_pk_sequence!)
    end

    it 'resyncs for :raw_upsert_all too' do
      2.times { |n| ImporterHooksSpecWidget.create!(name: "Existing #{n}", quantity: 0) }
      next_sequence_id = ImporterHooksSpecWidget.maximum(:id) + 1

      klass =
        upsert_importer_class do
          allow_primary_key_write true
          required_headers({ 'Id' => :id, 'Name' => :name, 'Quantity' => :quantity })
        end

      csv = write_csv(<<~CSV)
        Id,Name,Quantity
        #{next_sequence_id},Manually Inserted,1
      CSV

      klass.new(file_path: csv.path).import!

      expect { ImporterHooksSpecWidget.create!(name: 'Should Not Collide', quantity: 2) }.not_to raise_error
    end

    it 'resyncs for :activerecord too' do
      2.times { |n| ImporterHooksSpecWidget.create!(name: "Existing #{n}", quantity: 0) }
      next_sequence_id = ImporterHooksSpecWidget.maximum(:id) + 1

      klass =
        activerecord_importer_class do
          allow_primary_key_write true
          required_headers({ 'Id' => :id, 'Name' => :name, 'Quantity' => :quantity })
        end

      csv = write_csv(<<~CSV)
        Id,Name,Quantity
        #{next_sequence_id},Manually Inserted,1
      CSV

      klass.new(file_path: csv.path).import!

      expect { ImporterHooksSpecWidget.create!(name: 'Should Not Collide', quantity: 2) }.not_to raise_error
    end

    it 'resyncs for :activerecord_import too' do
      2.times { |n| ImporterHooksSpecWidget.create!(name: "Existing #{n}", quantity: 0) }
      next_sequence_id = ImporterHooksSpecWidget.maximum(:id) + 1

      klass =
        activerecord_import_importer_class do
          allow_primary_key_write true
          required_headers({ 'Id' => :id, 'Name' => :name, 'Quantity' => :quantity })
        end

      csv = write_csv(<<~CSV)
        Id,Name,Quantity
        #{next_sequence_id},Manually Inserted,1
      CSV

      klass.new(file_path: csv.path).import!

      expect { ImporterHooksSpecWidget.create!(name: 'Should Not Collide', quantity: 2) }.not_to raise_error
    end

    # Regression: found by an external review - reset_pk_sequence! runs after
    # the whole import's own transaction has already committed (see import!), so a
    # failure in the resync step alone used to make import! raise for a run whose rows
    # were, in fact, already durably written - reporting a successful import as failed,
    # which invites an unsafe retry against data that's already there.
    it 'does not raise from import! when the post-commit sequence resync itself fails - the import already committed' do
      klass =
        raw_importer_class do
          allow_primary_key_write true
          required_headers({ 'Id' => :id, 'Name' => :name, 'Quantity' => :quantity })
        end

      csv = write_csv(<<~CSV)
        Id,Name,Quantity
        1,Widget A,1
      CSV

      allow(ImporterHooksSpecWidget.connection).to receive(:reset_pk_sequence!).and_raise(ActiveRecord::StatementInvalid, 'boom')

      importer = klass.new(file_path: csv.path)

      expect { importer.import! }.not_to raise_error
      expect(ImporterHooksSpecWidget.find_by(name: 'Widget A')).to be_present
      expect(importer.logs).to include(a_hash_including(level: 'warning', message: /sequence resync failed/))
    end
  end
end
