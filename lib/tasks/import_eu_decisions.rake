namespace :import do

  desc 'Import EU decisions from csv file (usage: rake import:eu_decisions[path/to/file,path/to/another])'
  task :eu_decisions, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'eu_decisions_import'

    taxonomy_id = Taxonomy.where(:name => 'CITES_EU').first.id
    designation_id = Designation.find_by_name('EU').id
    puts "There are #{EuDecision.count} EU Decisions in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      sql = <<-SQL
        -- import eu_decision_types
        INSERT INTO eu_decision_types (name, created_at, updated_at)
        SELECT DISTINCT opinion, current_date, current_date FROM #{TMP_TABLE};

        -- import eu_decisions (both Opinions and Suspensions)
        INSERT INTO eu_decisions (taxon_concept_id, geo_entity_id, is_current,
          start_date, start_event_id, eu_decision_type_id, type, notes, internal_notes,
          created_at, updated_at)
        SELECT DISTINCT taxon_concepts.id, geo_entities.id, q.is_current,
          q.start_date, events.id, eu_decision_types.id,
          CASE
            WHEN q.opinion iLIKE 'suspension%'
            THEN 'EuSuspension'
            ELSE 'EuOpinion'
          END,
          q.notes, q.internal_notes,
          current_date, current_date
        FROM
        (select DISTINCT event_legacy_id, legacy_id, rank, kingdom, country_iso2,
          opinion, start_date, is_current,
          notes, internal_notes
        from #{TMP_TABLE} ) as q
        INNER JOIN ranks ON UPPER(ranks.name) = BTRIM(UPPER(q.rank))
        INNER JOIN taxon_concepts ON taxon_concepts.legacy_id = q.legacy_id
          AND UPPER(taxon_concepts.legacy_type) = BTRIM(UPPER(q.kingdom))
          AND taxon_concepts.rank_id = ranks.id
        INNER JOIN geo_entities ON UPPER(geo_entities.iso_code2) = BTRIM(UPPER(q.country_iso2))
        INNER JOIN eu_decision_types ON UPPER(eu_decision_types.name) = BTRIM(UPPER(q.opinion))
        INNER JOIN events ON events.legacy_id = q.event_legacy_id
          AND events.designation_id = #{designation_id}
        WHERE taxon_concepts.taxonomy_id = #{taxonomy_id};

        -- import eu_decision_parts
        INSERT INTO eu_decision_parts (is_current, source_id, term_id, eu_decision_id,
          created_at, updated_at)
        SELECT DISTINCT t.is_current, sources.id, terms.id, eu_decisions.id,
          current_date, current_date
        FROM #{TMP_TABLE} AS t
        INNER JOIN trade_codes AS sources ON UPPER(sources.code) = BTRIM(UPPER(t.source))
        INNER JOIN trade_codes AS terms ON UPPER(terms.code) = BTRIM(UPPER(t.term))
        -- prepare to match on the eu_decisions table
        INNER JOIN ranks ON UPPER(ranks.name) = BTRIM(UPPER(t.rank))
        INNER JOIN taxon_concepts ON taxon_concepts.legacy_id = t.legacy_id
          AND UPPER(taxon_concepts.legacy_type) = BTRIM(UPPER(t.kingdom))
          AND taxon_concepts.rank_id = ranks.id
        INNER JOIN geo_entities ON UPPER(geo_entities.iso_code2) = BTRIM(UPPER(t.country_iso2))
        INNER JOIN eu_decision_types ON UPPER(eu_decision_types.name) = BTRIM(UPPER(t.opinion))
        INNER JOIN events ON events.legacy_id = t.event_legacy_id
          AND events.designation_id = #{designation_id}
        INNER JOIN eu_decisions ON eu_decisions.taxon_concept_id = taxon_concepts.id
          AND eu_decisions.start_event_id = events.id
          AND eu_decisions.geo_entity_id = geo_entities.id
          AND eu_decisions.start_date = t.start_date
          AND eu_decisions.eu_decision_type_id = eu_decision_types.id
          AND eu_decisions.type = CASE
            WHEN t.opinion ilIKE 'suspension%'
              THEN 'EuSuspension'
            ELSE 'EuOpinion'
          END
        WHERE taxon_concepts.taxonomy_id = #{taxonomy_id};
      SQL
      puts "Importing eu decision types and eu decisions"
      puts sql
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{EuDecision.count} EU decisions in the database"
  end

end

