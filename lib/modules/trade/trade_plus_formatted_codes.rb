class Trade::TradePlusFormattedCodes

  VIEW_DIR = 'db/views/trade_plus_formatted_data_view'.freeze

  def initialize
    @mapping = YAML.load_file("#{Rails.root}/lib/data/trade_mapping.yml")
    @query = formatted_query
  end

  def generate_view(timestamp)
    Dir.mkdir(VIEW_DIR) unless Dir.exists?(VIEW_DIR)
    File.open("#{VIEW_DIR}/#{timestamp}.sql", 'w') { |f| f.write(@query) }
  end

  # TODO This is a draft for a generated WITH AS table containing
  # all possible mappings. It currently accounts only for units and terms.
  # Taxon names and groups should probably be added
  def codes_mapping_table
    codes_map = @mapping['rules']['standardise_terms'] +
          @mapping['rules']['standardise_units'] +
          @mapping['rules']['standardise_terms_and_units']

    rows = []
    codes_map.each do |rule|
      rows.concat generate_mapping_table_rows(rule)
    end

    columns = %w(
      term_id term_code term_name
      unit_id unit_code unit_name
      output_term_id output_term_code output_term_name
      output_unit_id output_unit_code output_unit_name
      taxa_field term_quantity_modifier term_modifier_value
      unit_quantity_modifier unit_modifier_value
    )

    <<-SQL
      WITH codes_map(#{columns.join(',')}) AS (
        VALUES #{rows.join(',')}
      )
    SQL
  end

  private

  ATTRIBUTES = {
    id: 'ts.id',
    year: 'ts.year',
    appendix: 'ts.appendix',
    reported_by_exporter: 'ts.reported_by_exporter',
    taxon_id: 'ts.taxon_concept_id',
    author_year: 'ts.taxon_concept_author_year',
    name_status: 'ts.taxon_concept_name_status',
    taxon_name: 'ts.taxon_concept_full_name',
    kingdom_name: 'ts.taxon_concept_kingdom_name',
    kingdom_id: 'ts.taxon_concept_kingdom_id',
    phylum_name: 'ts.taxon_concept_phylum_name',
    phylum_id: 'ts.taxon_concept_phylum_id',
    class_name: 'ts.taxon_concept_class_name',
    class_id: 'ts.taxon_concept_class_id',
    order_name: 'ts.taxon_concept_order_name',
    order_id: 'ts.taxon_concept_order_id',
    family_name: 'ts.taxon_concept_family_name',
    family_id: 'ts.taxon_concept_family_id',
    genus_name: 'ts.taxon_concept_genus_name',
    genus_id: 'ts.taxon_concept_genus_id',
    group_name: 'ts.group',
    quantity: 'ts.quantity',
    exporter_id: 'exporters.id',
    exporter_iso: 'exporters.iso_code2',
    exporter: 'exporters.name_en',
    importer_id: 'importers.id',
    importer_iso: 'importers.iso_code2',
    importer: 'importers.name_en',
    origin_id: 'origins.id',
    origin_iso: 'origins.iso_code2',
    origin: 'origins.name_en',
    purpose_id: 'purposes.id',
    purpose: 'purposes.name_en',
    source_id: 'sources.id',
    source: 'sources.name_en',
    rank_id: 'ranks.id',
    rank_name: 'ranks.name'
  }.freeze
  GROUP_EXTRA_ATTRIBUTES = %w(
    quantity ts.term_id terms.code terms.name_en ts.unit_id units.code units.name_en
  ).freeze
  def formatted_query
    attributes = ATTRIBUTES.map { |k, v| "#{v} AS #{k}" }.join(',')
    group_by_attributes = [ATTRIBUTES.values, GROUP_EXTRA_ATTRIBUTES].flatten.join(',')
    <<-SQL
      #{codes_mapping_table}
      SELECT #{attributes},
             COALESCE(MAX(COALESCE(output_term_id, codes_map.term_id)), ts.term_id) AS term_id,
             COALESCE(MAX(COALESCE(output_term_code, codes_map.term_code)), terms.code)  AS term_code,
             COALESCE(MAX(COALESCE(output_term_name, codes_map.term_name)), terms.name_en) AS term,
             COALESCE(MAX(COALESCE(output_unit_id, codes_map.unit_id)), ts.unit_id) AS unit_id,
             COALESCE(MAX(COALESCE(output_unit_code, codes_map.unit_code)), units.code) AS unit_code,
             COALESCE(MAX(COALESCE(output_unit_name, codes_map.unit_name)), units.name_en) AS unit,
             MAX(term_quantity_modifier) AS term_quantity_modifier,
             MAX(term_modifier_value)::INT AS term_modifier_value,
             MAX(unit_quantity_modifier) AS unit_quantity_modifier,
             MAX(unit_modifier_value)::INT AS unit_modifier_value
        FROM trade_plus_group_view ts
        LEFT OUTER JOIN codes_map ON (
          (
            codes_map.term_id = ts.term_id AND
            (codes_map.unit_id = ts.unit_id OR codes_map.unit_id = -1 AND ts.unit_id IS NULL) AND
            (

              ts.taxon_concept_kingdom_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'kingdom', ',')) OR
              ts.taxon_concept_phylum_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'phylum', ',')) OR
              ts.taxon_concept_class_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'class', ',')) OR
              ts.taxon_concept_order_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'order', ',')) OR
              ts.taxon_concept_family_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'family', ',')) OR
              ts.taxon_concept_genus_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'genus', ',')) OR
              ts.taxon_concept_full_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'taxon_name', ',')) OR
              ts.group = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'group', ','))
            )
          ) OR
          (
            codes_map.term_id = ts.term_id AND
            (codes_map.unit_id = ts.unit_id OR codes_map.unit_id = -1 AND ts.unit_id IS NULL) AND
            codes_map.taxa_field IS NULL
          ) OR
          (
            codes_map.term_id = ts.term_id AND codes_map.unit_id IS NULL AND
            (
              ts.taxon_concept_kingdom_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'kingdom', ',')) OR
              ts.taxon_concept_phylum_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'phylum', ',')) OR
              ts.taxon_concept_class_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'class', ',')) OR
              ts.taxon_concept_order_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'order', ',')) OR
              ts.taxon_concept_family_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'family', ',')) OR
              ts.taxon_concept_genus_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'genus', ',')) OR
              ts.taxon_concept_full_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'taxon_name', ',')) OR
              ts.group = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'group', ','))
            )
          ) OR
          (
            (codes_map.unit_id = ts.unit_id OR codes_map.unit_id = -1 AND ts.unit_id IS NULL) AND
             codes_map.term_id IS NULL AND
            (
              ts.taxon_concept_kingdom_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'kingdom', ',')) OR
              ts.taxon_concept_phylum_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'phylum', ',')) OR
              ts.taxon_concept_class_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'class', ',')) OR
              ts.taxon_concept_order_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'order', ',')) OR
              ts.taxon_concept_family_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'family', ',')) OR
              ts.taxon_concept_genus_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'genus', ',')) OR
              ts.taxon_concept_full_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'taxon_name', ',')) OR
              ts.group = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'group', ','))
            )
          ) OR
          (codes_map.term_id = ts.term_id AND codes_map.unit_id IS NULL AND codes_map.taxa_field IS NULL) OR
          (
            (codes_map.unit_id = ts.unit_id OR codes_map.unit_id = -1 AND ts.unit_id IS NULL) AND
            codes_map.term_id IS NULL AND
            codes_map.taxa_field IS NULL
          ) OR
          (
            codes_map.term_id IS NULL AND codes_map.unit_id IS NULL AND
            (
              ts.taxon_concept_kingdom_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'kingdom', ',')) OR
              ts.taxon_concept_phylum_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'phylum', ',')) OR
              ts.taxon_concept_class_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'class', ',')) OR
              ts.taxon_concept_order_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'order', ',')) OR
              ts.taxon_concept_family_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'family', ',')) OR
              ts.taxon_concept_genus_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'genus', ',')) OR
              ts.taxon_concept_full_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'taxon_name', ',')) OR
              ts.group = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'group', ','))
            )
          )
        )
        LEFT OUTER JOIN trade_codes terms ON ts.term_id = terms.id
        LEFT OUTER JOIN trade_codes units ON ts.unit_id = units.id
        LEFT OUTER JOIN trade_codes sources ON ts.source_id = sources.id
        LEFT OUTER JOIN trade_codes purposes ON ts.purpose_id = purposes.id
        INNER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
        LEFT OUTER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
        LEFT OUTER JOIN geo_entities importers ON ts.importer_id = importers.id
        LEFT OUTER JOIN geo_entities origins ON ts.country_of_origin_id = origins.id
        WHERE #{exemptions}
        GROUP BY #{group_by_attributes}
    SQL
  end

  def old_query
    <<-SQL
      SELECT ts.id, ts.year, ts.appendix, ts.reported_by_exporter,
               ts.taxon_concept_id AS taxon_id,
               ts.taxon_concept_author_year AS author_year,
               ts.taxon_concept_name_status AS name_status,
               ts.taxon_concept_full_name AS taxon_name,
               ts.taxon_concept_kingdom_name AS kingdom_name,
               ts.taxon_concept_kingdom_id AS kingdom_id,
               ts.taxon_concept_phylum_name AS phylum_name,
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
               exporters.id AS exporter_id,
               exporters.iso_code2 AS exporter_iso,
               exporters.name_en AS exporter,
               importers.id AS importer_id,
               importers.iso_code2 AS importer_iso,
               importers.name_en AS importer,
               origins.id AS origin_id,
               origins.iso_code2 AS origin_iso,
               origins.name_en AS origin,
               purposes.id AS purpose_id,
               purposes.name_en AS purpose,
               sources.id AS source_id,
               sources.name_en AS source,
               ranks.id AS rank_id,
               ranks.name AS rank_name
        FROM trade_plus_group_view ts
        LEFT OUTER JOIN trade_codes sources ON ts.source_id = sources.id
        LEFT OUTER JOIN trade_codes purposes ON ts.purpose_id = purposes.id
        INNER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
        LEFT OUTER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
        LEFT OUTER JOIN geo_entities importers ON ts.importer_id = importers.id
        LEFT OUTER JOIN geo_entities origins ON ts.country_of_origin_id = origins.id
        WHERE #{exemptions}
    SQL
  end

  TERM_MAPPING = {
    'terms'=> 'ts.term_id',
    'genus'=> 'ts.taxon_concept_genus_name',
    'units'=> 'ts.unit_id',
    'taxa'=> 'ts.taxon_concept_full_name',
    'group'=> 'ts.group',
    'appendices' => 'ts.appendix',
    'order' => 'ts.taxon_concept_order_name'
  }.freeze

  def exemptions
    query = []
    map = @mapping['rules']['exclusions']
    map.each do |exemp|
      key = exemp.first
      values = ''
      if ['terms', 'units'].include?(key)
        model = key.classify.constantize
        obj_ids = model.where(code: exemp.second).map(&:id)
        values = obj_ids.join(',')
      else
        values = exemp.second.map { |a| "'#{a}'" }.join(',')
      end
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
      query += "#{indent(9)}WHEN "
      formatted_input = input_flattening(rule)
      formatted_input.delete_if { |_, v| v.empty? }
      subquery = []
      formatted_input.each do |input|
        values = ''
        if ['terms', 'units'].include?(input.first)
          model = input.first.classify.constantize
          obj_ids = model.where(code: input.second).map(&:id)
          values = obj_ids.join(',')
        else
          values = Array(input.second).map { |a| "'#{a}'" }.join(',')
        end
        if values.present?
          subquery << "#{TERM_MAPPING[input.first]} IN (#{values})"
        else
          subquery << "#{TERM_MAPPING[input.first]} IS NULL"
        end
      end
      query += subquery.join(' AND ')
      query += "\n#{indent(9)}THEN "
      output = output_formatting(rule)

      term = output['term'].blank? ? 'term_id' : "#{Term.find_by_code(output['term']).id}"
      unit = output['unit'].blank? ? 'unit_id' : output['unit'] == 'NULL' ? 'NULL' : "#{Unit.find_by_code(output['unit']).id}"
      modifier = output['quantity_modifier'] || '+'
      value = output['modifier_value'] || ''
      added_quantity = value.present? ? "#{modifier}#{value}" : ''
      output_query = "\n#{indent(10)}Array[#{term}, (ts.quantity#{added_quantity}), #{unit}]\n"
      query += output_query
    end
    query += "#{indent(9)}ELSE#{indent(10)}Array[term_id, ts.quantity, unit_id]\n"
    query += "\n#{indent(9)}END AS term_quantity_unit," #formatted_codes_array
  end

  def input_flattening(rule)
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

  def indent(tabs_num = 0)
    tabs = ''
    tabs.tap { tabs_num.times { tabs << "\t" } }
  end

  # TODO This is a draft for a generated WITH AS table
  TAXONOMY_FIELDS = %w(kingdom phylum order class family genus taxon).freeze
  def generate_mapping_table_rows(rule)
    formatted_input = input_flattening(rule)
    formatted_input.delete_if { |_, v| v.empty? }
    output = output_formatting(rule)
    modifier = output['quantity_modifier'] ? "'#{output['quantity_modifier']}'" : 'NULL'
    value = output['modifier_value'].to_i || 'NULL'

    input_terms = formatted_input['terms'] || [nil]
    input_units = formatted_input['units'] || [nil]
    input_taxa_fields = formatted_input.slice(*TAXONOMY_FIELDS)
    input_taxa_fields = input_taxa_fields.present? ? "'#{input_taxa_fields.to_s.gsub(/=>/,':')}'::JSON" : 'NULL'

    output_term_values = slice_values(output['term'], 'term')
    output_unit_values = slice_values(output['unit'], 'unit')

    input_terms_values = []
    input_units_values = []
    modifier_values = ''
    rows = []

    input_terms.each do |input_term|
      input_terms_values << slice_values(input_term, 'term')
      modifier_values = [modifier, value, 'NULL', 'NULL'].join(',')
    end
    input_units.each do |input_unit|
      input_units_values << slice_values(input_unit, 'unit')
      modifier_values = ['NULL', 'NULL', modifier, value].join(',')
    end
    input_values = input_terms_values.product(input_units_values)
    input_values = input_values.map { |v| "#{v[0]},#{v[1]}" }
    input_values.each do |input_codes|
      rows << "(#{input_codes},#{output_term_values},#{output_unit_values},#{input_taxa_fields},#{modifier_values})"
    end
    rows
  end

  # TODO This is a draft for a generated WITH AS table
  TRADE_CODE_FIELDS = %w(id code name_en).freeze
  def slice_values(trade_code, code_type)
    return ("NULL," * 3).chop unless trade_code
    return [-1, 'NULL', 'NULL'].join(',') if trade_code == 'NULL'

    code_obj = code_type.capitalize.constantize.find_by_code(trade_code)
    code_obj.attributes.slice(*TRADE_CODE_FIELDS).values.map { |v| v.is_a?(String) ? "'#{v}'" : v }.join(',')
  end
end
