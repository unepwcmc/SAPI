class CreateAnnotationsView < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE VIEW annotations_view AS
      WITH multilingual_annotations AS (
        SELECT annotation_id_mul,
        english_note[1] AS english_full_note, english_note[2] AS english_short_note,
        spanish_note[1] AS spanish_full_note, spanish_note[2] AS spanish_short_note,
        french_note[1] AS french_full_note, french_note[2] AS french_short_note
        FROM
        CROSSTAB(
          'SELECT annotations.id AS annotation_id_mul,
          SUBSTRING(languages.name FROM 1 FOR 1) AS lng,
          ARRAY[annotation_translations.full_note, annotation_translations.short_note]
          FROM "annotations"
          INNER JOIN "annotation_translations"
            ON "annotation_translations"."annotation_id" = "annotations"."id" 
          INNER JOIN "languages"
            ON "languages"."id" = "annotation_translations"."language_id"
          ORDER BY 1,2'
        ) AS ct(
          annotation_id_mul INTEGER,
          english_note TEXT[], spanish_note TEXT[], french_note TEXT[]
        )
      )
      SELECT
        listing_changes.id AS id,
        generic_annotations.symbol,
        generic_annotations.parent_symbol,
        multilingual_generic_annotations.english_full_note AS generic_english_full_note,
        multilingual_generic_annotations.spanish_full_note AS generic_spanish_full_note,
        multilingual_generic_annotations.french_full_note AS generic_french_full_note,
        multilingual_specific_annotations.english_full_note,
        multilingual_specific_annotations.spanish_full_note,
        multilingual_specific_annotations.french_full_note,
        multilingual_specific_annotations.english_short_note,
        multilingual_specific_annotations.spanish_short_note,
        multilingual_specific_annotations.french_short_note
      FROM
        listing_changes
        LEFT JOIN annotations AS specific_annotations ON
          specific_annotations.listing_change_id = listing_changes.id
        LEFT JOIN annotations AS generic_annotations ON
          generic_annotations.id = listing_changes.annotation_id
        LEFT JOIN multilingual_annotations AS multilingual_specific_annotations
          ON specific_annotations.id = multilingual_specific_annotations.annotation_id_mul
        LEFT JOIN multilingual_annotations AS multilingual_generic_annotations
          ON generic_annotations.id = multilingual_generic_annotations.annotation_id_mul
    SQL
    Sapi::rebuild_annotations_mview
  end

  def down
    execute "DROP VIEW annotations_view"
  end
end
