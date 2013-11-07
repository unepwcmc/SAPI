namespace :import do

  desc 'Import trade codes'
  task :trade_codes => [:environment] do
    puts "#{TradeCode.delete_all} trade codes deleted"
    terms = [
      {:code => 'BAL', :name_en => 'baleen'},
      {:code => 'BAR', :name_en => 'bark'},
      {:code => 'BEL', :name_en => 'belts'},
      {:code => 'BOD', :name_en => 'bodies'},
      {:code => 'BOC', :name_en => 'bone carvings'},
      {:code => 'BOP', :name_en => 'bone pieces'},
      {:code => 'BPR', :name_en => 'bone products'},
      {:code => 'BON', :name_en => 'bones'},
      {:code => 'CAL', :name_en => 'calipee'},
      {:code => 'CAP', :name_en => 'carapaces'},
      {:code => 'CAR', :name_en => 'carvings'},
      {:code => 'CAV', :name_en => 'caviar'},
      {:code => 'CST', :name_en => 'chess sets'},
      {:code => 'CHP', :name_en => 'chips'},
      {:code => 'CLA', :name_en => 'claws'},
      {:code => 'CLO', :name_en => 'cloth'},
      {:code => 'COS', :name_en => 'coral sand'},
      {:code => 'CUL', :name_en => 'cultures'},
      {:code => 'DER', :name_en => 'derivatives'},
      {:code => 'DPL', :name_en => 'dried plants'},
      {:code => 'EAR', :name_en => 'ears'},
      {:code => 'EGG', :name_en => 'eggs'},
      {:code => 'EGL', :name_en => 'eggs (live)'},
      {:code => 'EXT', :name_en => 'extract'},
      {:code => 'FEA', :name_en => 'feathers'},
      {:code => 'FOO', :name_en => 'feet'},
      {:code => 'FIB', :name_en => 'fibres'},
      {:code => 'FIG', :name_en => 'fingerlings'},
      {:code => 'FIN', :name_en => 'fins'},
      {:code => 'FPT', :name_en => 'flower pots'},
      {:code => 'FLO', :name_en => 'flowers'},
      {:code => 'FRU', :name_en => 'fruit'},
      {:code => 'GAL', :name_en => 'gall'},
      {:code => 'GAB', :name_en => 'gall bladder(s)'},
      {:code => 'GAR', :name_en => 'garments'},
      {:code => 'GEN', :name_en => 'genitalia'},
      {:code => 'GRS', :name_en => 'graft rootstocks'},
      {:code => 'HAI', :name_en => 'hair'},
      {:code => 'HAP', :name_en => 'hair products'},
      {:code => 'HAN', :name_en => 'handbags'},
      {:code => 'HEA', :name_en => 'heads'},
      {:code => 'HOC', :name_en => 'horn carvings'},
      {:code => 'HOP', :name_en => 'horn pieces'},
      {:code => 'HPR', :name_en => 'horn products'},
      {:code => 'HOS', :name_en => 'horn scraps'},
      {:code => 'HOR', :name_en => 'horns'},
      {:code => 'FRN', :name_en => 'items of furniture'},
      {:code => 'IVC', :name_en => 'ivory carvings'},
      {:code => 'IVP', :name_en => 'ivory pieces'},
      {:code => 'IVS', :name_en => 'ivory scraps'},
      {:code => 'LEA', :name_en => 'leather'},
      {:code => 'SKO', :name_en => 'leather items'},
      {:code => 'LPL', :name_en => 'leather products (l)'},
      {:code => 'LPS', :name_en => 'leather products (s)'},
      {:code => 'LVS', :name_en => 'leaves'},
      {:code => 'LEG', :name_en => 'legs'},
      {:code => 'LIV', :name_en => 'live'},
      {:code => 'LOG', :name_en => 'logs'},
      {:code => 'MEA', :name_en => 'meat'},
      {:code => 'MED', :name_en => 'medicine'},
      {:code => 'MUS', :name_en => 'musk'},
      {:code => 'OIL', :name_en => 'oil'},
      {:code => 'OTH', :name_en => 'other'},
      {:code => 'SHO', :name_en => 'pairs of shoes'},
      {:code => 'PEA', :name_en => 'pearls'},
      {:code => 'PKY', :name_en => 'piano keys'},
      {:code => 'PIE', :name_en => 'pieces'},
      {:code => 'PLA', :name_en => 'plates'},
      {:code => 'PLY', :name_en => 'plywood'},
      {:code => 'POW', :name_en => 'powder'},
      {:code => 'QUI', :name_en => 'quills'},
      {:code => 'COR', :name_en => 'raw corals'},
      {:code => 'ROO', :name_en => 'roots'},
      {:code => 'SAW', :name_en => 'sawn wood'},
      {:code => 'SCA', :name_en => 'scales'},
      {:code => 'SCR', :name_en => 'scraps'},
      {:code => 'SEE', :name_en => 'seeds'},
      {:code => 'SHE', :name_en => 'shells'},
      {:code => 'SKD', :name_en => 'sides'},
      {:code => 'SID', :name_en => 'sides'},
      {:code => 'SKE', :name_en => 'skeletons'},
      {:code => 'SKP', :name_en => 'skin pieces'},
      {:code => 'SKS', :name_en => 'skin scraps'},
      {:code => 'SKI', :name_en => 'skins'},
      {:code => 'SKU', :name_en => 'skulls'},
      {:code => 'SOU', :name_en => 'soup'},
      {:code => 'SPE', :name_en => 'specimens'},
      {:code => 'FRA', :name_en => 'spectacle frames'},
      {:code => 'STE', :name_en => 'stems'},
      {:code => 'SWI', :name_en => 'swim bladders'},
      {:code => 'TAI', :name_en => 'tails'},
      {:code => 'TEE', :name_en => 'teeth'},
      {:code => 'TIM', :name_en => 'timber'},
      {:code => 'TIC', :name_en => 'timber carvings'},
      {:code => 'TIP', :name_en => 'timber pieces'},
      {:code => 'TIS', :name_en => 'tissue cultures'},
      {:code => 'TRO', :name_en => 'trophies'},
      {:code => 'TUS', :name_en => 'tusks'},
      {:code => 'UNS', :name_en => 'unspecified'},
      {:code => 'VEN', :name_en => 'veneer'},
      {:code => 'VNM', :name_en => 'venom'},
      {:code => 'WAL', :name_en => 'wallets'},
      {:code => 'WAT', :name_en => 'watchstraps'},
      {:code => 'WAX', :name_en => 'wax'},
      {:code => 'WOO', :name_en => 'wood products'}
    ]
    terms.each{ |t| Term.create(t) }

    sources = [
      {:code => 'A', :name_en => 'Artificially propagated plants'},
      {:code => 'C', :name_en => 'Captive-bred animals'},
      {:code => 'D', :name_en => 'Captive-bred/artificially propagated (Appendix I)'},
      {:code => 'F', :name_en => 'Born in captivity (F1 and subsequent)'},
      {:code => 'I', :name_en => 'Confiscations/seizures'},
      {:code => 'O', :name_en => 'Pre-Convention'},
      {:code => 'R', :name_en => 'Ranched'},
      {:code => 'U', :name_en => 'Unknown'},
      {:code => 'W', :name_en => 'Wild'}
    ]
    sources.each{ |t| Source.create(t) }

    purposes = [
      {:code => 'B', :name_en => 'Breeding in captivity or artificially propagation'},
      {:code => 'E', :name_en => 'Educational'},
      {:code => 'G', :name_en => 'Botanical garden'},
      {:code => 'H', :name_en => 'Hunting trophy'},
      {:code => 'L', :name_en => 'Law enforcement/judicial/forensic'},
      {:code => 'M', :name_en => 'Medical (including biomedical research)'},
      {:code => 'N', :name_en => 'Reintroduction or introduction into the wild'},
      {:code => 'P', :name_en => 'Personal'},
      {:code => 'Q', :name_en => 'Circus and travelling exhibitions'},
      {:code => 'S', :name_en => 'Scientific'},
      {:code => 'T', :name_en => 'Commercial'},
      {:code => 'Z', :name_en => 'Zoo'}
    ]
    purposes.each{ |t| Purpose.create(t) }

    units = [
      {:code => 'BAG', :name_en => 'Bags'},
      {:code => 'BAK', :name_en => 'Back skins'},
      {:code => 'BOT', :name_en => 'Bottles'},
      {:code => 'BOX', :name_en => 'Boxes'},
      {:code => 'BSK', :name_en => 'Belly skins'},
      {:code => 'CAN', :name_en => 'Cans'},
      {:code => 'CAS', :name_en => 'Cases'},
      {:code => 'CCM', :name_en => 'Cubic centimetres'},
      {:code => 'CRT', :name_en => 'Cartons'},
      {:code => 'CTM', :name_en => 'Centimetres'},
      {:code => 'CUF', :name_en => 'Cubic feet'},
      {:code => 'CUM', :name_en => 'Cubic metres'},
      {:code => 'FEE', :name_en => 'Feet'},
      {:code => 'FLA', :name_en => 'Flasks'},
      {:code => 'GRM', :name_en => 'Grams'},
      {:code => 'HRN', :name_en => 'Hornback skins'},
      {:code => 'INC', :name_en => 'Inches'},
      {:code => 'ITE', :name_en => 'Items'},
      {:code => 'KIL', :name_en => 'Kilograms'},
      {:code => 'LTR', :name_en => 'Litres'},
      {:code => 'MGM', :name_en => 'Milligrams'},
      {:code => 'MLT', :name_en => 'Millilitres'},
      {:code => 'MTR', :name_en => 'Metres'},
      {:code => 'MYG', :name_en => 'Micrograms'},
      {:code => 'OUN', :name_en => 'Ounces'},
      {:code => 'PAI', :name_en => 'Pairs'},
      {:code => 'PCS', :name_en => 'Pieces'},
      {:code => 'PND', :name_en => 'Pounds'},
      {:code => 'SET', :name_en => 'Sets'},
      {:code => 'SHP', :name_en => 'Shipments'},
      {:code => 'SID', :name_en => 'Sides'},
      {:code => 'SKI', :name_en => 'Skins'},
      {:code => 'SQC', :name_en => 'Square centimetres'},
      {:code => 'SQD', :name_en => 'Square decimetres'},
      {:code => 'SQF', :name_en => 'Square feet'},
      {:code => 'SQM', :name_en => 'Square metres'},
      {:code => 'TON', :name_en => 'Metric tons'},
      {:code => 'YAR', :name_en => 'yards'}
    ]
    units.each{ |t| Unit.create(t) }

    puts "#{TradeCode.count} trade codes created"
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
