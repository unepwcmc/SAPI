# One run of an importer over one file, for any importer on Importer::Base -
# not only the taxon mapping ones that prompted it.
#
# A run rather than an import: it may be queued, working, finished or failed,
# and naming the record for the finished case makes the other three read oddly.
# Importer::Base's own documentation already calls this record an ImportRun.
#
# A run outlives the request that started it - the largest mapping file is
# 209 MB and takes about two minutes - so what it leaves behind has to be
# readable afterwards, and the row-level errors the importer collects are worth
# keeping.
#
# Created before the mapping tables, which carry a foreign key to it: every row
# they hold came from one of these runs and is deleted with it.
class CreateImportRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :import_runs do |t|
      # What the import is about, where that is one record. Optional because
      # some imports target a combination rather than a row - the mapping match
      # files cover a pair of taxonomies, and neither side is the subject.
      t.references :importable, polymorphic: true, index: true

      # Which importer to run. A registry key rather than a class name, so a
      # class can be renamed without stranding old rows, and so nothing in the
      # database decides what code gets loaded.
      t.string :kind, null: false

      # Whatever else the importer needs and the polymorphic reference cannot
      # hold - for a match file, the second taxonomy.
      t.jsonb :params, null: false, default: {}

      t.string :status, null: false, default: 'pending'

      # Importer::Base#logs, verbatim. It is documented as a JSON-safe array of
      # hashes for exactly this, and keeping it whole means a failed import can
      # still name the file row that broke it.
      t.jsonb :logs, null: false, default: []

      t.datetime :started_at
      t.datetime :finished_at

      # Who uploaded it. There is no updated_by: the only thing that changes an
      # import after it is created is its own job, and "the job did it" is not
      # worth a column.
      #
      # Declared inside create_table because strong_migrations refuses a foreign
      # key added to a table that already holds rows, and a table created in the
      # same statement holds none.
      t.references :created_by, type: :integer, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :import_runs, :kind
    add_index :import_runs, [ :status, :created_at ]
  end
end
