namespace :import do

  desc 'Import trade codes'
  task :trade_codes => [:environment] do
    [Purpose, Source, Term, Unit].each do |klass|
      current_count = klass.count
      CSV.foreach("lib/files/#{klass.to_s.downcase}_codes_utf8.csv") do |row|
        code = klass.find_or_initialize_by(code: row[0].strip.upcase)
        code.update_attributes(:name_en => row[1].strip,
                               :name_fr => row[2].strip,
                               :name_es => row[3].strip)
      end
      puts "#{klass.count - current_count} new #{klass} added"
    end
  end

  desc "Import terms and purpose codes acceptable pairing"
  task :trade_codes_t_p_pairs, [:clear] => [:environment] do |t, args|
    TMP_TABLE = "terms_and_purpose_pairs_import"
    file = "lib/files/term_purpose_pairs_utf8.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)
    if args[:clear]
      puts "#{TermTradeCodesPair.where(:trade_code_type => 'Purpose').delete_all} TermPurposePairs deleted"
    end
    sql = <<-SQL
      INSERT INTO term_trade_codes_pairs(term_id,
        trade_code_id, trade_code_type, created_at, updated_at)
      SELECT subquery.*, NOW(), NOW()
      FROM (
        SELECT DISTINCT terms.id, trade_codes.id, 'Purpose'
        FROM #{TMP_TABLE}
        INNER JOIN trade_codes AS terms ON BTRIM(UPPER(terms.code)) = BTRIM(UPPER(#{TMP_TABLE}.TERM_CODE))
          AND terms.type = 'Term'
        LEFT JOIN trade_codes AS trade_codes ON BTRIM(UPPER(trade_codes.code)) = BTRIM(UPPER(#{TMP_TABLE}.PURPOSE_CODE))
          AND trade_codes.type = 'Purpose'

        EXCEPT

        SELECT DISTINCT term_id, trade_code_id, trade_code_type
        FROM term_trade_codes_pairs

      ) as subquery;
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "#{TermTradeCodesPair.where(:trade_code_type => 'Purpose').count} terms and purpose codes pairs created"
  end

  desc "Import terms and unit codes acceptable pairing"
  task :trade_codes_t_u_pairs, [:clear] => [:environment] do |t, args|
    TMP_TABLE = "terms_and_unit_pairs_import"
    file = "lib/files/term_unit_pairs_utf8.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)
    if args[:clear]
      puts "#{TermTradeCodesPair.where(:trade_code_type => 'Unit').delete_all} TermUnitPairs deleted"
    end
    sql = <<-SQL
      INSERT INTO term_trade_codes_pairs(term_id,
        trade_code_id, trade_code_type, created_at, updated_at)
      SELECT subquery.*, NOW(), NOW()
      FROM (
        SELECT DISTINCT terms.id, trade_codes.id, 'Unit'
        FROM #{TMP_TABLE}
        INNER JOIN trade_codes AS terms ON BTRIM(UPPER(terms.code)) = BTRIM(UPPER(#{TMP_TABLE}.TERM_CODE))
          AND terms.type = 'Term'
        LEFT JOIN trade_codes AS trade_codes ON BTRIM(UPPER(trade_codes.code)) = BTRIM(UPPER(#{TMP_TABLE}.UNIT_CODE))
          AND trade_codes.type = 'Unit'

        EXCEPT

        SELECT DISTINCT term_id, trade_code_id, trade_code_type
        FROM term_trade_codes_pairs

      ) AS subquery;
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "#{TermTradeCodesPair.where(:trade_code_type => 'Unit').count} terms and unit codes pairs created"
  end

  desc "Import taxon concepts terms acceptable pairing. (i.e.: which terms can go with each taxon concept)"
  task :taxon_concept_terms_pairs, [:clear] => [:environment] do |t, args|
    TMP_TABLE = "taxon_concepts_and_terms_pairs_import"
    file = "lib/files/taxon_concept_term_pairs_utf8.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)
    if args[:clear]
      puts "#{Trade::TaxonConceptTermPair.delete_all} taxon_concept_term_pairs deleted"
    end
    sql = <<-SQL
      INSERT INTO trade_taxon_concept_term_pairs(taxon_concept_id, term_id,
        created_at, updated_at)
      SELECT subquery.*, NOW(), NOW()
      FROM (
        SELECT DISTINCT taxon_concepts.id, terms.id
        FROM #{TMP_TABLE}
        INNER JOIN taxon_concepts_mview AS taxon_concepts ON UPPER(BTRIM(taxon_concepts.full_name)) = UPPER(BTRIM(#{TMP_TABLE}.TAXON_FAMILY))
          AND UPPER(BTRIM(taxon_concepts.rank_name)) = UPPER(BTRIM(#{TMP_TABLE}.RANK))
        INNER JOIN trade_codes AS terms ON UPPER(BTRIM(terms.code)) = UPPER(BTRIM(#{TMP_TABLE}.TERM_CODE))
          AND terms.type = 'Term'
        WHERE taxon_concepts.taxonomy_is_cites_eu

        EXCEPT

        SELECT taxon_concept_id, term_id
        FROM trade_taxon_concept_term_pairs

      ) AS subquery;
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "#{Trade::TaxonConceptTermPair.count} terms and unit codes pairs created"
  end

  desc "Empties taxon_concept_term_pairs and term_trade_codes_pairs"
  task :clear_acceptable_pairs => [:environment] do
    puts "#{TermTradeCodesPair.delete_all} term_trade_codes_pairs deleted"
    puts "#{Trade::TaxonConceptTermPair.delete_all} taxon_concept_term_pairs deleted"
  end
end
