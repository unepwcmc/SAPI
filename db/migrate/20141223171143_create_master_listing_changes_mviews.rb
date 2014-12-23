class CreateMasterListingChangesMviews < ActiveRecord::Migration
  def change
    [:cites, :eu, :cms].each do |designation|
      listing_changes_mview = "#{designation}_listing_changes_mview"

      # create master cites/eu/cms listing changes mview
      execute <<-SQL
      CREATE TABLE master_#{listing_changes_mview}
      (
        taxon_concept_id integer,
        id integer,
        original_taxon_concept_id integer,
        effective_at timestamp without time zone,
        species_listing_id integer,
        species_listing_name character varying(255),
        change_type_id integer,
        change_type_name character varying(255),
        designation_id integer,
        designation_name character varying(255),
        parent_id integer,
        nomenclature_note_en text,
        nomenclature_note_fr text,
        nomenclature_note_es text,
        party_id integer,
        party_iso_code character varying(255),
        party_full_name_en character varying(255),
        party_full_name_es character varying(255),
        party_full_name_fr character varying(255),
        ann_symbol character varying(255),
        full_note_en text,
        full_note_es text,
        full_note_fr text,
        short_note_en text,
        short_note_es text,
        short_note_fr text,
        display_in_index boolean,
        display_in_footnote boolean,
        hash_ann_symbol character varying(255),
        hash_ann_parent_symbol character varying(255),
        hash_full_note_en text,
        hash_full_note_es text,
        hash_full_note_fr text,
        inclusion_taxon_concept_id integer,
        inherited_short_note_en text,
        inherited_full_note_en text,
        inherited_short_note_es text,
        inherited_full_note_es text,
        inherited_short_note_fr text,
        inherited_full_note_fr text,
        auto_note_en text,
        auto_note_es text,
        auto_note_fr text,
        is_current boolean,
        explicit_change boolean,
        updated_at timestamp without time zone,
        show_in_history boolean,
        show_in_downloads boolean,
        show_in_timeline boolean,
        listed_geo_entities_ids integer[],
        excluded_geo_entities_ids integer[],
        excluded_taxon_concept_ids integer[],
        dirty boolean,
        expiry timestamp with time zone,
        event_id integer
      )
      SQL
      if table_exists?(listing_changes_mview)
        unless column_exists?(listing_changes_mview, :event_id)
          execute "ALTER TABLE #{listing_changes_mview} ADD COLUMN event_id INT"
        end
        execute <<-SQL
        UPDATE #{listing_changes_mview}
        SET event_id = listing_changes.event_id
        FROM listing_changes
        WHERE listing_changes.id = #{listing_changes_mview}.id
        SQL

        # rename to child cites/eu/cms listing changes mview
        # and link to master
        execute <<-SQL
        ALTER TABLE #{listing_changes_mview}
        RENAME TO child_#{listing_changes_mview};
        ALTER TABLE child_#{listing_changes_mview}
        INHERIT master_#{listing_changes_mview};
        SQL
      end

      # rename master
      execute <<-SQL
      ALTER TABLE master_#{listing_changes_mview}
      RENAME TO #{listing_changes_mview};
      SQL
    end
  end
end
