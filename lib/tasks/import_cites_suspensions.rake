namespace :import do

  desc 'Import CITES suspensions from csv file (usage: rake import:cites_suspensions[path/to/file,path/to/another])'
  task :cites_suspensions, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'cites_suspensions_import'

    if CitesSuspension.any?
      puts "Removing CitesSuspensions related records"
      puts "#{CitesSuspensionConfirmation.delete_all} suspension confirmations deleted"
      puts "#{TradeRestrictionSource.
        where(:trade_restriction_id => CitesSuspension.select(:id)).
        delete_all} trade restriction Sources deleted"
      puts "#{TradeRestrictionTerm.
        where(:trade_restriction_id => CitesSuspension.select(:id)).
        delete_all} trade restriction Term deleted"
      puts "#{TradeRestrictionPurpose.
        where(:trade_restriction_id => CitesSuspension.select(:id)).
        delete_all} trade restriction Purposes deleted"
      puts "#{CitesSuspension.delete_all} suspensions deleted"
    end

    puts "There are #{CitesSuspension.count} CITES suspensions in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      taxonomy_id = Taxonomy.where(:name => Taxonomy::CITES_EU).first.id
      cites_id = Designation.where(:name => Designation::CITES).first.id

      sql = <<-SQL
        WITH suspensions_with_ids AS (
          WITH suspensions_per_exclusion AS (
            SELECT
              kingdom,
              rank,
              legacy_id,
              country_iso2,
              start_notification_legacy_id,
              end_notification_legacy_id,
              CASE
                WHEN exclusions IS NULL THEN NULL
                ELSE split_part(regexp_split_to_table(exclusions,','),':',1)
              END AS exclusion_rank,
              CASE
                WHEN exclusions IS NULL THEN NULL
                ELSE split_part(regexp_split_to_table(exclusions,','),':',2)
              END AS exclusion_legacy_id,
              is_current,
              notes
            FROM #{TMP_TABLE}
          )
          SELECT
              taxon_concepts.id AS taxon_concept_id,
              geo_entities.id AS geo_entity_id,
              start_notification.id AS start_notification_id,
              start_notification.effective_at AS start_date,
              end_notification.id AS end_notification_id,
              end_notification.effective_at AS end_date,
              ARRAY(
                SELECT *
                FROM UNNEST(ARRAY_AGG(exclusion_taxon_concepts.id)) s
                WHERE s IS NOT NULL
              )::VARCHAR AS exclusions,
              suspensions_per_exclusion.is_current,
              suspensions_per_exclusion.notes

          FROM suspensions_per_exclusion
           LEFT JOIN geo_entities
              ON UPPER(geo_entities.iso_code2) = UPPER(BTRIM(suspensions_per_exclusion.country_iso2))
              AND geo_entities.legacy_type IN ('#{GeoEntityType::COUNTRY}', '#{GeoEntityType::TERRITORY}')
            LEFT JOIN ranks
              ON UPPER(ranks.name) = UPPER(BTRIM(suspensions_per_exclusion.rank))
            LEFT JOIN ranks exclusion_ranks
              ON LOWER(exclusion_ranks.name) = LOWER(BTRIM(exclusion_rank))
            LEFT JOIN taxon_concepts
              ON taxon_concepts.legacy_id = suspensions_per_exclusion.legacy_id
              AND UPPER(taxon_concepts.legacy_type) = UPPER(BTRIM(suspensions_per_exclusion.kingdom))
              AND taxon_concepts.taxonomy_id = #{taxonomy_id}
              AND taxon_concepts.rank_id = ranks.id
            LEFT JOIN taxon_concepts exclusion_taxon_concepts
              ON exclusion_taxon_concepts.legacy_id = exclusion_legacy_id::INTEGER
              AND exclusion_taxon_concepts.legacy_type = suspensions_per_exclusion.kingdom
              AND exclusion_taxon_concepts.rank_id = exclusion_ranks.id
            LEFT JOIN events start_notification
              ON start_notification.designation_id = #{cites_id}
              AND start_notification.legacy_id = suspensions_per_exclusion.start_notification_legacy_id
            LEFT JOIN events end_notification
              ON end_notification.designation_id = #{cites_id}
              AND end_notification.legacy_id = suspensions_per_exclusion.end_notification_legacy_id
            GROUP BY
              taxon_concepts.id,
              geo_entities.id,
              start_notification.id,
              end_notification.id,
              suspensions_per_exclusion.is_current,
              suspensions_per_exclusion.notes
          )
        INSERT INTO trade_restrictions(
          taxon_concept_id,
          geo_entity_id,
          start_notification_id,
          start_date,
          end_notification_id,
          end_date,
          is_current,
          notes,
          type,
          created_at,
          updated_at
        )
        SELECT
          taxon_concept_id,
          geo_entity_id,
          start_notification_id,
          start_date,
          end_notification_id,
          end_date,
          is_current,
          notes,
          'CitesSuspension',
          NOW(),
          NOW()
        FROM suspensions_with_ids
      SQL

      ActiveRecord::Base.connection.execute(sql)
    end

    puts "There are now #{CitesSuspension.count} CITES suspensions in the database"
  end

end
