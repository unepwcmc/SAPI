namespace :import do
  desc 'Apply name status changes from csv file (usage: rake import:taxon_name_status_changes[path/to/file,path/to/another])'
  task :taxon_notes, 10.times.map { |i| :"file_#{i}" } => [ :environment ] do |t, args|
    import_helper = CsvImportHelper.new

    TMP_TABLE = 'taxon_notes'

    files = import_helper.files_from_args(t, args)

    ApplicationRecord.transaction do
      files.each do |file|
        import_helper.drop_table(TMP_TABLE)
        import_helper.create_table_from_csv_headers(file, TMP_TABLE)
        import_helper.copy_data(file, TMP_TABLE)

        # Note: this will make NO changes to taxons where the IDs are not found,
        # and will simply ignore them.
        #
        # This is so we can test more easily on staging, which may not have all
        # the required taxons.
        result = ActiveRecord::Base.connection.execute(
          <<-SQL
            WITH note_changes AS (
              SELECT
                id::BIGINT AS id,
                internal_distribution_note
              FROM #{TMP_TABLE}
              WHERE id !=''
                AND internal_distribution_note !=''
            ), updated_comments AS (
              UPDATE comments
              -- if there is any actual content (not spaces or empty p tags)
              -- then append to the note. Otherwise, replace it.
              SET note = CASE
                WHEN note ~ '[\w]{2,}'
                THEN note || chr(10) || chr(10) || itc.internal_distribution_note
                ELSE itc.internal_distribution_note
                END,
                updated_at = NOW()
              FROM note_changes itc
              WHERE commentable_type = 'TaxonConcept'
                AND comment_type = 'Distribution'
                AND commentable_id = itc.id
              RETURNING 'U' AS operation, comments.*
            ), inserted_comments AS (
              INSERT INTO
                comments (
                  commentable_id,
                  commentable_type,
                  comment_type,
                  note,
                  created_at,
                  updated_at
                )
              SELECT
                itc.id                         AS commentable_id,
                'TaxonConcept'                 AS commentable_type,
                'Distribution'                 AS comment_type,
                itc.internal_distribution_note AS note,
                NOW()                          AS created_at,
                NOW()                          AS updated_at
              FROM note_changes itc
              -- Ensure that we do not insert comments for taxons which do not
              -- exist
              JOIN taxon_concepts tc
                ON tc.id = itc.id
              -- Ensure that we do not insert comments where we have already
              -- update the comment
              LEFT JOIN updated_comments uc
                ON uc.commentable_id = itc.id
              WHERE uc.id IS NULL
              RETURNING 'I' AS operation, comments.*
            )
            SELECT
              operation,
              commentable_id AS taxon_concept_id,
              id             AS comment_id
            FROM inserted_comments
            UNION ALL
            SELECT
              operation,
              commentable_id AS taxon_concept_id,
              id             AS comment_id
            FROM updated_comments
            UNION ALL
            SELECT
              NULL AS operation,
              id   AS taxon_concept_id,
              NULL AS comment_id
            FROM note_changes itc WHERE NOT EXISTS (
              SELECT 1 FROM inserted_comments ic WHERE itc.id = ic.commentable_id
            ) AND NOT EXISTS (
              SELECT 1 FROM updated_comments uc WHERE itc.id = uc.commentable_id
            );
          SQL
        )

        puts result.ntuples

        result.each do |row|
          puts row
        end

        import_helper.rollback_if_dry_run

        puts 'Committing'
      end
    end
  end
end
