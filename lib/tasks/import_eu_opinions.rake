namespace :import do
  desc 'Import EU decisions from csv file (usage: rake import:eu_opinions[path/to/file,path/to/another])'
  task :eu_opinions, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'eu_opinions_import'

    taxonomy_id = Taxonomy.where(:name => 'CITES_EU').first.id
    puts "There are #{EuOpinion.count} EU opinions in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      # At this time there are no specific requirements regarding designation,
      # hence why there are no checks related to designation_id for events
      sql = <<-SQL
        WITH tt AS (
          SELECT t.*,
            events.id AS start_event_id,
            eu_decision_types.id AS eu_decision_type_id,
            geo_entities.id AS geo_entity_id,
            terms.id AS term_id,
            sources.id AS source_id
          FROM #{TMP_TABLE} t
          JOIN taxon_concepts ON taxon_concepts.id = t.taxon_concept_id
          JOIN events ON events.name = t.start_event_name
          JOIN eu_decision_types ON t.opinion_name = eu_decision_types.name -- Eu Decision Type can be empty now. Consider LEFT JOIN if importing other files
          JOIN geo_entities ON SQUISH_NULL(t.country_name) = geo_entities.name_en
          LEFT JOIN trade_codes terms on t.term_code = terms.code
          LEFT JOIN trade_codes sources on t.source_code = sources.code
          WHERE taxon_concepts.taxonomy_id = #{taxonomy_id}
        )
        INSERT INTO eu_decisions (taxon_concept_id, geo_entity_id, is_current,
          start_date, start_event_id, eu_decision_type_id, source_id, term_id, type,
          notes, internal_notes, nomenclature_note_en, nomenclature_note_es, nomenclature_note_fr,
          created_at, updated_at)
        SELECT DISTINCT taxon_concept_id, geo_entity_id, is_current,
          start_date::DATE, start_event_id, eu_decision_type_id, source_id, term_id, 'EuOpinion',
          notes, internal_notes, nomenclature_note_en, nomenclature_note_es, nomenclature_note_fr,
          CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        FROM tt
      SQL

      puts "Importing eu opinions"
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{EuOpinion.count} EU opinions in the database"
  end
end
