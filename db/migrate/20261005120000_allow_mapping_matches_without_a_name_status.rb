# A match a person asserted carries no name status: no automatic rule fired, so
# the pipeline writes NA on both sides. The October CITES-IUCN export has three,
# all pairs whose names differ on each side - exactly the matches software
# cannot find and a curator has to state.
#
# Status stays NOT NULL for every other row only by convention; the database
# cannot express "unless confidence_level is verified", and the three rows are
# worth more than the constraint.
class AllowMappingMatchesWithoutANameStatus < ActiveRecord::Migration[8.1]
  def change
    # Not a bulk change_table, which is what Rails/BulkChangeTable asks for:
    # strong_migrations cannot see inside one and refuses the whole migration
    # unless it is wrapped in safety_assured, and silencing a safety check to
    # satisfy a lint is the wrong way round. Dropping NOT NULL updates the
    # catalog without rewriting the table, so there is nothing to batch anyway.
    # rubocop:disable Rails/BulkChangeTable
    change_column_null :mapping_matches, :matched_name_status, true
    change_column_null :mapping_matches, :foreign_matched_name_status, true
    # rubocop:enable Rails/BulkChangeTable
  end
end
