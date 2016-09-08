namespace :update do
  task :eu_decisions_with_missing_source => [:environment] do
    TMP_TABLE = "eu_decisions_with_missing_source"
    file = "lib/files/eu_decisions_with_missing_source.csv"
    drop_table(TMP_TABLE)
    db_columns = ['full_name', 'rank_name', 'start_date', 'party_name', 'decision_type', 'source_code', 'term_code', 'notes']
    create_table_from_column_array(TMP_TABLE, db_columns.map { |c| "#{c} TEXT" })
    # Full Name Rank  Date of Decision  Party EU Decision Source  Term  Notes
    copy_data_into_table(file, TMP_TABLE, db_columns)

    wild_source = Source.find_by_code('W')

    update_query = <<-SQL
    WITH tt AS (
      select t.*
      ,taxon_concepts.id AS taxon_concept_id
      ,geo_entities.id AS geo_entity_id
      ,eu_decision_types.id AS eu_decision_type_id
      ,terms.id AS term_id
      from eu_decisions_with_missing_source t
      JOIN taxon_concepts ON t.full_name = taxon_concepts.full_name AND name_status = 'A'
      JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id AND taxonomies.name = 'CITES_EU'
      JOIN ranks ON t.rank_name = ranks.name AND ranks.id = taxon_concepts.rank_id
      JOIN geo_entities ON geo_entities.name_en = SQUISH_NULL(t.party_name)
      JOIN eu_decision_types ON t.decision_type = CASE
          WHEN eu_decision_types.name ~* '^i+\\)'
          THEN '(No opinion) ' || eu_decision_types.name
          ELSE eu_decision_types.name
        END
      LEFT JOIN trade_codes terms on terms.type = 'Term' AND (terms.name_en = t.term_code)
    ), matched_eu_decisions AS (
      SELECT tt.*, eu_decisions.id
      FROM tt
      JOIN eu_decisions
      ON eu_decisions.taxon_concept_id = tt.taxon_concept_id
      AND eu_decisions.geo_entity_id = tt.geo_entity_id
      AND eu_decisions.eu_decision_type_id = tt.eu_decision_type_id
      AND (eu_decisions.term_id = tt.term_id OR eu_decisions.term_id IS NULL AND tt.term_id IS NULL)
      AND eu_decisions.start_date = tt.start_date::DATE
    )
    UPDATE eu_decisions SET source_id = #{wild_source.id}
    FROM matched_eu_decisions
    WHERE matched_eu_decisions.id = eu_decisions.id;
    SQL

    res = ActiveRecord::Base.connection.execute update_query
    puts "#{res.cmd_tuples} rows linked to 'W' source"
  end
end
