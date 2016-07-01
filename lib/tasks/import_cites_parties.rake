namespace :import do
  desc 'Import CITES parties'
  task :cites_parties => [:environment] do
    parties_iso_codes = %w( AF AL DZ AG AR AM AU AT AZ BS BH BD BB BY BE BZ BJ BT BO BA BW BR BN BG BF BI KH CM CA CV CF TD CL CN CO KM CG CR CI HR CU CY CZ CD DK DJ DM DO EC EG SV GQ ER EE ET FJ FI FR GA GM GE DE GH GR GD GT GN GW GY HN HU IS IN ID IR IE IL IT JM JP JO KZ KE KW KG LA LV LB LS LR LY LI LT LU MG MW MY MV ML MT MR MU MX MC MN ME MA MZ MM NA NP NL NZ NI NE NG NO OM PK PW PA PG PY PE PH PL PT QA KR MD RO RU RW KN LC VC WS SM ST SA SN RS SC SL SG SK SI SB SO ZA ES LK SD SR SZ SE CH SY TH MK TG TT TN TR UG UA AE GB TZ US UY UZ VU VE VN YE ZM ZW)
    parties_iso_codes_pg_ary = parties_iso_codes.map { |ic| "'#{ic}'" }.join(',')
    sql = <<-SQL
      INSERT INTO designation_geo_entities (designation_id, geo_entity_id, created_at, updated_at)
      SELECT subquery.*, NOW(), NOW()
      FROM (
        SELECT designations.id, geo_entities.id
        FROM UNNEST(ARRAY[#{parties_iso_codes_pg_ary}]) AS new_iso_code2
        JOIN geo_entities ON geo_entities.iso_code2 = new_iso_code2
        JOIN designations
          ON designations.name = '#{Designation::CITES}'
          EXCEPT
            SELECT q.designation_id, q.geo_entity_id FROM designation_geo_entities q
            INNER JOIN designations ON q.designation_id = designations.id
            WHERE designations.name = '#{Designation::CITES}'
      ) AS subquery
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end
end
