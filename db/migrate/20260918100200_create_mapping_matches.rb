class CreateMappingMatches < ActiveRecord::Migration[8.1]
  def change
    create_table :mapping_matches, id: :uuid do |t|
      t.references :matchable_taxonomy, null: false, foreign_key: true, index: false
      t.string :taxon_nid, null: false
      t.references :foreign_matchable_taxonomy, null: false, index: false,
        foreign_key: { to_table: :matchable_taxonomies }
      t.string :foreign_taxon_nid, null: false

      # The names the match was actually made on, and the status each held.
      # Read together the two statuses are the match type - AA, SA, AS or SS -
      # so it is not stored separately. Denormalised rather than referenced:
      # mapping_taxa is cleared and reloaded per platform, which would orphan
      # every foreign key into it on each upload.
      t.string :matched_name, null: false
      t.string :matched_name_status, null: false
      t.string :foreign_matched_name, null: false
      t.string :foreign_matched_name_status, null: false

      t.string :match_confidence, null: false
      t.boolean :exclude, null: false, default: false
      # The run that wrote this row - see the same column on mapping_taxa.
      t.references :import_run, null: false, foreign_key: true

      t.timestamps
    end

    # Both sides are indexed because a lookup can arrive from either - there is
    # one file per unordered pair and no reverse file - and because replacing a
    # pair has to find it in whichever orientation the source file used.
    add_index :mapping_matches, [ :matchable_taxonomy_id, :taxon_nid ],
      name: 'index_mapping_matches_on_near_side'
    add_index :mapping_matches, [ :foreign_matchable_taxonomy_id, :foreign_taxon_nid ],
      name: 'index_mapping_matches_on_foreign_side'
  end
end
