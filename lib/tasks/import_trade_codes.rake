namespace :import do

  desc 'Import trade codes'
  task :trade_codes => [:environment] do
    [Purpose, Source, Term, Unit].each do |klass|
      current_count = klass.count
      CSV.foreach("lib/files/#{klass.to_s.downcase}_codes_utf8.csv") do |row|
        code = klass.find_or_initialize_by_code(row[0].strip.upcase)
        code.update_attributes(:name_en => row[1].strip,
                               :name_fr => row[2].strip,
                               :name_es => row[3].strip)
      end
      puts "#{klass.count - current_count} new #{klass} added"
    end
  end

  desc "Import terms and purpose codes acceptable pairing"
  task :trade_codes_t_p_pairs => [:environment] do
    TMP_TABLE = "terms_and_purpose_pairs_import"
    file = "lib/files/term_purpose_pairs_utf8.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)
    initial_count = TermTradeCodesPair.count
    sql = <<-SQL
      INSERT INTO term_trade_codes_pairs(term_id,
        trade_code_id, trade_code_type, created_at, updated_at)
      SELECT DISTINCT terms.id, trade_codes.id,
        trade_codes.type, current_date, current_date
      FROM #{TMP_TABLE}
      INNER JOIN trade_codes AS terms ON BTRIM(UPPER(terms.code)) = BTRIM(UPPER(#{TMP_TABLE}.TERM_CODE))
        AND terms.type = 'Term'
      INNER JOIN trade_codes AS trade_codes ON BTRIM(UPPER(trade_codes.code)) = BTRIM(UPPER(#{TMP_TABLE}.PURPOSE_CODE))
        AND trade_codes.type = 'Purpose';
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "#{TermTradeCodesPair.count - initial_count} terms and purpose codes pairs created"
  end

  desc "Import terms and unit codes acceptable pairing"
  task :trade_codes_t_u_pairs => [:environment] do
    TMP_TABLE = "terms_and_unit_pairs_import"
    file = "lib/files/term_unit_pairs_utf8.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)
    initial_count = TermTradeCodesPair.count
    sql = <<-SQL
      INSERT INTO term_trade_codes_pairs(term_id,
        trade_code_id, trade_code_type, created_at, updated_at)
      SELECT DISTINCT terms.id, trade_codes.id,
        trade_codes.type, current_date, current_date
      FROM #{TMP_TABLE}
      INNER JOIN trade_codes AS terms ON BTRIM(UPPER(terms.code)) = BTRIM(UPPER(#{TMP_TABLE}.TERM_CODE))
        AND terms.type = 'Term'
      INNER JOIN trade_codes AS trade_codes ON BTRIM(UPPER(trade_codes.code)) = BTRIM(UPPER(#{TMP_TABLE}.UNIT_CODE))
        AND trade_codes.type = 'Unit';
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "#{TermTradeCodesPair.count - initial_count} terms and unit codes pairs created"
  end

  desc "Import taxon concepts terms acceptable pairing. (i.e.: which terms can go with each taxon concept)"
  task :taxon_concept_terms_pairs => [:environment] do
    TMP_TABLE = "taxon_concepts_and_terms_pairs_import"
    file = "lib/files/taxon_concept_term_pairs_utf8.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)
    initial_count = Trade::TaxonConceptTermPair.count
    sql = <<-SQL
      INSERT INTO trade_taxon_concept_term_pairs(taxon_concept_id, term_id,
        created_at, updated_at)
      SELECT DISTINCT taxon_concepts.id, terms.id, current_date, current_date
      FROM #{TMP_TABLE}
      INNER JOIN taxon_concepts_mview AS taxon_concepts ON UPPER(BTRIM(taxon_concepts.full_name)) = UPPER(BTRIM(#{TMP_TABLE}.TAXON_FAMILY))
      INNER JOIN trade_codes AS terms ON UPPER(BTRIM(terms.code)) = UPPER(BTRIM(#{TMP_TABLE}.TERM_CODE))
        AND terms.type = 'Term'
      WHERE taxon_concepts.rank_name = '#{Rank::FAMILY}' AND taxon_concepts.taxonomy_is_cites_eu
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "#{Trade::TaxonConceptTermPair.count - initial_count} terms and unit codes pairs created"
  end
end
