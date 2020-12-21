task :set_eu_opinions_to_not_current => :environment do
  TMP_TABLE = 'eu_opinions_to_not_current'
  filename = 'lib/files/eu_opinions_4404_Conolophus_to_be_reset_to_not_current.csv'
  drop_table(TMP_TABLE)
  db_columns = %w(taxon_concept_id start_regulation_name country_name start_date opinion_name term_code source_code is_current)
  create_table_from_column_array(TMP_TABLE, db_columns.map { |c| c == 'taxon_concept_id' ? "#{c} INTEGER" : "#{c} TEXT" })
  copy_data_into_table(filename, TMP_TABLE, db_columns)

  query = <<-SQL
    WITH tt AS (
      SELECT t.*,
        events.id AS start_event_id,
        eu_decision_types.id AS eu_decision_type_id,
        geo_entities.id AS geo_entity_id,
        terms.id AS term_id,
        sources.id AS source_id
      FROM #{TMP_TABLE} t
      JOIN events ON events.name = t.start_regulation_name
      JOIN eu_decision_types ON t.opinion_name = eu_decision_types.name -- Eu Decision Type can be empty now. Consider LEFT JOIN if importing other files
      JOIN geo_entities ON SQUISH_NULL(t.country_name) = geo_entities.name_en
      LEFT JOIN trade_codes terms on t.term_code = terms.code
      LEFT JOIN trade_codes sources on t.source_code = sources.code
    ), matched_eu_opinions AS (
      SELECT tt.*, eu_decisions.id
      FROM tt
      JOIN eu_decisions
      ON eu_decisions.taxon_concept_id = tt.taxon_concept_id
      AND eu_decisions.geo_entity_id = tt.geo_entity_id
      AND eu_decisions.start_event_id = tt.start_event_id
      AND eu_decisions.eu_decision_type_id = tt.eu_decision_type_id
      AND (eu_decisions.term_id = tt.term_id OR eu_decisions.term_id IS NULL AND tt.term_id IS NULL)
      AND (eu_decisions.source_id = tt.source_id OR eu_decisions.source_id IS NULL AND tt.source_id IS NULL)
      AND eu_decisions.start_date = tt.start_date::DATE
      AND eu_decisions.is_current
      AND eu_decisions.type = 'EuOpinion'
    )
    UPDATE eu_decisions SET is_current = false, updated_at = CURRENT_TIMESTAMP
    FROM matched_eu_opinions
    WHERE matched_eu_opinions.id = eu_decisions.id;
  SQL

  res = ActiveRecord::Base.connection.execute(query)
  puts "#{res.cmd_tuples} rows updated with is_current to false"
end
