namespace :ephemeral do
  ##
  # See ticket sustainability-assessment-tool 333
  # https://unep-wcmc.codebasehq.com/projects/sustainability-assessment-tool/tickets/333
  #
  # Run in dry-run mode by default:
  #   bundle exec rake ephemeral:backfill_geo_entity_iso_code3
  # Persist changes explicitly:
  #   DRY_RUN=false bundle exec rake ephemeral:backfill_geo_entity_iso_code3
  #
  # No geo entity has an iso_code3, and nothing else sets it. This fills it in
  # from iso_code2 for current geo entities, from the 249 officially assigned
  # ISO 3166-1 codes, plus two agreed for #333: Netherlands Antilles (AN,
  # withdrawn from ISO) gets ANT, and Serbia (Kosovo) (KV) gets XKX, the code
  # in common use for Kosovo. Left without one: the trade-only codes (XX, XV,
  # HS), the European Union (EU), Clipperton (CP, pending a decision) and every
  # geo entity that is not current. An iso_code3 already set is kept, so this
  # is safe to re-run.
  #
  # Saving through the model clears the GeoEntitySearch cache, so the API
  # serves the new codes straight away.
  task backfill_geo_entity_iso_code3: :environment do
    ISO_CODE3_BY_ISO_CODE2 = {
      'AD' => 'AND', 'AE' => 'ARE', 'AF' => 'AFG', 'AG' => 'ATG', 'AI' => 'AIA', 'AL' => 'ALB', 'AM' => 'ARM', 'AO' => 'AGO',
      'AQ' => 'ATA', 'AR' => 'ARG', 'AS' => 'ASM', 'AT' => 'AUT', 'AU' => 'AUS', 'AW' => 'ABW', 'AX' => 'ALA', 'AZ' => 'AZE',
      'BA' => 'BIH', 'BB' => 'BRB', 'BD' => 'BGD', 'BE' => 'BEL', 'BF' => 'BFA', 'BG' => 'BGR', 'BH' => 'BHR', 'BI' => 'BDI',
      'BJ' => 'BEN', 'BL' => 'BLM', 'BM' => 'BMU', 'BN' => 'BRN', 'BO' => 'BOL', 'BQ' => 'BES', 'BR' => 'BRA', 'BS' => 'BHS',
      'BT' => 'BTN', 'BV' => 'BVT', 'BW' => 'BWA', 'BY' => 'BLR', 'BZ' => 'BLZ', 'CA' => 'CAN', 'CC' => 'CCK', 'CD' => 'COD',
      'CF' => 'CAF', 'CG' => 'COG', 'CH' => 'CHE', 'CI' => 'CIV', 'CK' => 'COK', 'CL' => 'CHL', 'CM' => 'CMR', 'CN' => 'CHN',
      'CO' => 'COL', 'CR' => 'CRI', 'CU' => 'CUB', 'CV' => 'CPV', 'CW' => 'CUW', 'CX' => 'CXR', 'CY' => 'CYP', 'CZ' => 'CZE',
      'DE' => 'DEU', 'DJ' => 'DJI', 'DK' => 'DNK', 'DM' => 'DMA', 'DO' => 'DOM', 'DZ' => 'DZA', 'EC' => 'ECU', 'EE' => 'EST',
      'EG' => 'EGY', 'EH' => 'ESH', 'ER' => 'ERI', 'ES' => 'ESP', 'ET' => 'ETH', 'FI' => 'FIN', 'FJ' => 'FJI', 'FK' => 'FLK',
      'FM' => 'FSM', 'FO' => 'FRO', 'FR' => 'FRA', 'GA' => 'GAB', 'GB' => 'GBR', 'GD' => 'GRD', 'GE' => 'GEO', 'GF' => 'GUF',
      'GG' => 'GGY', 'GH' => 'GHA', 'GI' => 'GIB', 'GL' => 'GRL', 'GM' => 'GMB', 'GN' => 'GIN', 'GP' => 'GLP', 'GQ' => 'GNQ',
      'GR' => 'GRC', 'GS' => 'SGS', 'GT' => 'GTM', 'GU' => 'GUM', 'GW' => 'GNB', 'GY' => 'GUY', 'HK' => 'HKG', 'HM' => 'HMD',
      'HN' => 'HND', 'HR' => 'HRV', 'HT' => 'HTI', 'HU' => 'HUN', 'ID' => 'IDN', 'IE' => 'IRL', 'IL' => 'ISR', 'IM' => 'IMN',
      'IN' => 'IND', 'IO' => 'IOT', 'IQ' => 'IRQ', 'IR' => 'IRN', 'IS' => 'ISL', 'IT' => 'ITA', 'JE' => 'JEY', 'JM' => 'JAM',
      'JO' => 'JOR', 'JP' => 'JPN', 'KE' => 'KEN', 'KG' => 'KGZ', 'KH' => 'KHM', 'KI' => 'KIR', 'KM' => 'COM', 'KN' => 'KNA',
      'KP' => 'PRK', 'KR' => 'KOR', 'KW' => 'KWT', 'KY' => 'CYM', 'KZ' => 'KAZ', 'LA' => 'LAO', 'LB' => 'LBN', 'LC' => 'LCA',
      'LI' => 'LIE', 'LK' => 'LKA', 'LR' => 'LBR', 'LS' => 'LSO', 'LT' => 'LTU', 'LU' => 'LUX', 'LV' => 'LVA', 'LY' => 'LBY',
      'MA' => 'MAR', 'MC' => 'MCO', 'MD' => 'MDA', 'ME' => 'MNE', 'MF' => 'MAF', 'MG' => 'MDG', 'MH' => 'MHL', 'MK' => 'MKD',
      'ML' => 'MLI', 'MM' => 'MMR', 'MN' => 'MNG', 'MO' => 'MAC', 'MP' => 'MNP', 'MQ' => 'MTQ', 'MR' => 'MRT', 'MS' => 'MSR',
      'MT' => 'MLT', 'MU' => 'MUS', 'MV' => 'MDV', 'MW' => 'MWI', 'MX' => 'MEX', 'MY' => 'MYS', 'MZ' => 'MOZ', 'NA' => 'NAM',
      'NC' => 'NCL', 'NE' => 'NER', 'NF' => 'NFK', 'NG' => 'NGA', 'NI' => 'NIC', 'NL' => 'NLD', 'NO' => 'NOR', 'NP' => 'NPL',
      'NR' => 'NRU', 'NU' => 'NIU', 'NZ' => 'NZL', 'OM' => 'OMN', 'PA' => 'PAN', 'PE' => 'PER', 'PF' => 'PYF', 'PG' => 'PNG',
      'PH' => 'PHL', 'PK' => 'PAK', 'PL' => 'POL', 'PM' => 'SPM', 'PN' => 'PCN', 'PR' => 'PRI', 'PS' => 'PSE', 'PT' => 'PRT',
      'PW' => 'PLW', 'PY' => 'PRY', 'QA' => 'QAT', 'RE' => 'REU', 'RO' => 'ROU', 'RS' => 'SRB', 'RU' => 'RUS', 'RW' => 'RWA',
      'SA' => 'SAU', 'SB' => 'SLB', 'SC' => 'SYC', 'SD' => 'SDN', 'SE' => 'SWE', 'SG' => 'SGP', 'SH' => 'SHN', 'SI' => 'SVN',
      'SJ' => 'SJM', 'SK' => 'SVK', 'SL' => 'SLE', 'SM' => 'SMR', 'SN' => 'SEN', 'SO' => 'SOM', 'SR' => 'SUR', 'SS' => 'SSD',
      'ST' => 'STP', 'SV' => 'SLV', 'SX' => 'SXM', 'SY' => 'SYR', 'SZ' => 'SWZ', 'TC' => 'TCA', 'TD' => 'TCD', 'TF' => 'ATF',
      'TG' => 'TGO', 'TH' => 'THA', 'TJ' => 'TJK', 'TK' => 'TKL', 'TL' => 'TLS', 'TM' => 'TKM', 'TN' => 'TUN', 'TO' => 'TON',
      'TR' => 'TUR', 'TT' => 'TTO', 'TV' => 'TUV', 'TW' => 'TWN', 'TZ' => 'TZA', 'UA' => 'UKR', 'UG' => 'UGA', 'UM' => 'UMI',
      'US' => 'USA', 'UY' => 'URY', 'UZ' => 'UZB', 'VA' => 'VAT', 'VC' => 'VCT', 'VE' => 'VEN', 'VG' => 'VGB', 'VI' => 'VIR',
      'VN' => 'VNM', 'VU' => 'VUT', 'WF' => 'WLF', 'WS' => 'WSM', 'YE' => 'YEM', 'YT' => 'MYT', 'ZA' => 'ZAF', 'ZM' => 'ZMB',
      'ZW' => 'ZWE'
    }.freeze
    # Not officially assigned ISO 3166-1 codes; see above.
    OTHER_ISO_CODE3_BY_ISO_CODE2 = { 'AN' => 'ANT', 'KV' => 'XKX' }.freeze
    # Default to a dry run so this one-off data fix can be verified safely
    # before it is allowed to persist changes in production-like environments.
    DRY_RUN = ENV.fetch('DRY_RUN', 'true')
    dry_run = ActiveModel::Type::Boolean.new.cast(DRY_RUN)

    ApplicationRecord.transaction do
      geo_entities = GeoEntity.current.where.not(iso_code2: nil).order(:iso_code2)

      geo_entities.each do |geo_entity|
        iso_code3 = ISO_CODE3_BY_ISO_CODE2[geo_entity.iso_code2] ||
          OTHER_ISO_CODE3_BY_ISO_CODE2[geo_entity.iso_code2]

        if iso_code3.nil?
          puts "Skipped #{geo_entity.iso_code2} #{geo_entity.name_en}: no iso_code3 to give it" if geo_entity.iso_code3.nil?
        elsif geo_entity.iso_code3.nil?
          geo_entity.update!(iso_code3: iso_code3)
        elsif geo_entity.iso_code3 != iso_code3
          puts "Kept #{geo_entity.iso_code2} #{geo_entity.name_en}: has #{geo_entity.iso_code3}, expected #{iso_code3}"
        end
      end

      filled = geo_entities.where.not(iso_code3: nil).count
      puts "#{filled} of #{geo_entities.count} current geo entities with an iso_code2 now have an iso_code3"

      # Use an explicit rollback instead of a generic error so the task keeps the
      # transaction behavior intentional and predictable for dry-run verification.
      if dry_run
        puts 'Dry run: rolling back'
        raise ActiveRecord::Rollback, 'Dry run: rollback'
      end
    end
  end
end
