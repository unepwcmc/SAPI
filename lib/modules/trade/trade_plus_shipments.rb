class Trade::TradePlusShipments

  VIEW_DIR = 'db/views/trade_plus_with_taxa_view'.freeze

  def initialize
    @mapping = YAML.load_file("#{Rails.root}/lib/data/trade_mapping.yml")
    @query = formatted_query
  end

  def generate_view(timestamp)
    Dir.mkdir(VIEW_DIR) unless Dir.exists?(VIEW_DIR)
    File.open("#{VIEW_DIR}/#{timestamp}.sql", 'w') { |f| f.write(@query) }
  end

  private

  def formatted_query
    <<-SQL
      SELECT DISTINCT *
      FROM(
          SELECT ts.id, ts.year, ts.appendix, ts.taxon_concept_id,
                 ts.taxon_concept_author_year AS author_year,
                 ts.taxon_concept_name_status AS name_status,
                 ts.taxon_concept_full_name AS taxon_name,
                 ts.taxon_concept_phylum_id AS phylum_id,
                 ts.taxon_concept_class_id AS class_id,
                 ts.taxon_concept_class_name AS class_name,
                 ts.taxon_concept_order_id AS order_id,
                 ts.taxon_concept_order_name AS order_name,
                 ts.taxon_concept_family_id AS family_id,
                 ts.taxon_concept_family_name AS family_name,
                 ts.taxon_concept_genus_id AS genus_id,
                 ts.taxon_concept_genus_name AS genus_name,
                 ts.group AS group_name,
                 CASE #{standard_trade_codes}
                 -- terms.id AS term_id,
                 -- terms.name_en AS term,
                 -- units.id AS unit_id,
                 -- units.name_en AS unit,
                 exporters.id AS exporter_id,
                 exporters.iso_code2 AS exporter_iso,
                 exporters.name_en AS exporter,
                 importers.id AS importer_id,
                 importers.iso_code2 AS importer_iso,
                 importers.name_en AS importer,
                 origins.iso_code2 AS origin,
                 purposes.id AS purpose_id,
                 purposes.name_en AS purpose,
                 sources.id AS source_id,
                 sources.name_en AS source,
                 ranks.id AS rank_id,
                 ranks.name AS rank_name,
          FROM trade_plus_group_view ts
          INNER JOIN species_listings listings ON listings.abbreviation = ts.appendix
          INNER JOIN trade_codes sources ON ts.source_id = sources.id
          INNER JOIN trade_codes purposes ON ts.purpose_id = purposes.id
          INNER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
          LEFT OUTER JOIN trade_codes terms ON ts.term_id = terms.id
          LEFT OUTER JOIN trade_codes units ON ts.unit_id = units.id
          LEFT OUTER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
          LEFT OUTER JOIN geo_entities importers ON ts.importer_id = importers.id
          LEFT OUTER JOIN geo_entities origins ON ts.country_of_origin_id = origins.id
          WHERE listings.designation_id = 1
          AND #{exemptions}
        ) AS s
    SQL
  end

  TERM_MAPPING = {
    'terms'=> 'terms.code',
    'genus'=> 'ts.taxon_concept_genus_name',
    'units'=> 'units.code',
    'taxa'=> 'ts.taxon_concept_full_name',
    'group'=> 'ts.group',
    'appendices' => 'ts.appendix'
  }.freeze

  def exemptions
    query = []
    map = @mapping['rules']['exclusions']
    map.each do |exemp|
      key = exemp.first
      values = exemp.second.map { |a| "'#{a}'" }.join(',')
      query << " #{TERM_MAPPING[key]} NOT IN (#{values})\n"
    end
    query.join("\t\t\t\t\tAND ")
  end

  def standard_trade_codes
    map = @mapping['rules']['standardise_terms'] +
          @mapping['rules']['standardise_units'] +
          @mapping['rules']['standardise_terms_and_units']
    query = ''
    map.each do |rule|
      query += "\t\t\t\t\t\t\t\t\tWHEN "
      formatted_input = input_flatting(rule)
      formatted_input.delete_if { |_, v| v.empty? }
      subquery = []
      formatted_input.each do |input|
        values = Array(input.second).map { |a| "'#{a}'" }.join(',')
        subquery << "#{TERM_MAPPING[input.first]} IN (#{values})"
      end
      query += subquery.join(' AND ')
      query += "\n\t\t\t\t\t\t\t\t\tTHEN "
      output = output_formatting(rule)
      modifier = output['quantity_modifier'] || '+'
      value = output['modifier_value'] || 0
      output_query = "\n\t\t\t\t\t\t\t\t\t\tCASE WHEN ts.reported_by_exporter IS FALSE THEN Array['#{output['term'] || 'terms.code'}', ts.quantity#{modifier}#{value}::text, NULL, '#{output['unit'] || 'units.code'}']
                      ELSE Array['#{output['term'] || 'terms.code'}', NULL, ts.quantity#{modifier}#{value}::text, '#{output['unit'] || 'units.code'}']
                      END\n"
      query += output_query
    end
    query += "\n\t\t\t\t\t\t\t\t\t AS term_imp_exp_unit," #formatted_codes_array
  end

  def input_flatting(rule)
    input = rule['input']
    input.each_with_object({}) do |(k, v), h|
      v.is_a?(Hash) ? v.map { |key, value| h[key] = value } : h[k] = v
    end
  end

  def output_formatting(rule)
    output = rule['output']
    output = output.select { |k, v| ['term', 'unit'].include? k } if output['quantity_modifier'].blank?
    output
  end

end
