class MoveAnnotationTranslationsToAnnotations < ActiveRecord::Migration
  def change
    execute <<-SQL
    UPDATE annotations
    SET short_note_en = english_annotation.short_note, full_note_en = english_annotation.full_note
    FROM
    annotations q
    INNER JOIN annotation_translations english_annotation
    ON english_annotation.annotation_id = q.id
    INNER JOIN languages
    ON english_annotation.language_id = languages.id AND UPPER(languages.iso_code1) = 'EN'
    WHERE annotations.id = q.id
    SQL
    execute <<-SQL
    UPDATE annotations
    SET short_note_en = french_annotation.short_note, full_note_en = french_annotation.full_note
    FROM
    annotations q
    INNER JOIN annotation_translations french_annotation
    ON french_annotation.annotation_id = q.id
    INNER JOIN languages
    ON french_annotation.language_id = languages.id AND UPPER(languages.iso_code1) = 'FR'
    WHERE annotations.id = q.id
    SQL
    execute <<-SQL
    UPDATE annotations
    SET short_note_en = spanish_annotation.short_note, full_note_en = spanish_annotation.full_note
    FROM
    annotations q
    INNER JOIN annotation_translations spanish_annotation
    ON spanish_annotation.annotation_id = q.id
    INNER JOIN languages
    ON spanish_annotation.language_id = languages.id AND UPPER(languages.iso_code1) = 'ES'
    WHERE annotations.id = q.id
    SQL
    execute <<-SQL
    UPDATE listing_changes
    SET annotation_id = annotations.id
    FROM annotations WHERE annotations.listing_change_id = listing_changes.id
    SQL
  end
end
