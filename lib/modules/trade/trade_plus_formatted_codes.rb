class Trade::TradePlusFormattedCodes

  VIEW_DIR = 'db/views/trade_plus_with_taxa_view'.freeze

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
    )

    <<-SQL
      WITH codes_map(#{columns.join(',')}) AS (
        VALUES #{rows.join(',')}
      )
    SQL
  end


  private

  def formatted_query
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
        INNER JOIN trade_codes sources ON ts.source_id = sources.id
        INNER JOIN trade_codes purposes ON ts.purpose_id = purposes.id
        INNER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
        LEFT OUTER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
        LEFT OUTER JOIN geo_entities importers ON ts.importer_id = importers.id
        LEFT OUTER JOIN geo_entities origins ON ts.country_of_origin_id = origins.id
        WHERE #{exemptions}
    SQL
  end

  TERM_MAPPING = {
    'terms'=> 'term_id',
    'genus'=> 'ts.taxon_concept_genus_name',
    'units'=> 'unit_id',
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
        model = key.chop.capitalize.constantize
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
          model = input.first.chop.capitalize.constantize
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
      #byebug if output['term'].present? && !Term.find_by_code(output['term'])
      #byebug if output['unit'].present? && !Unit.find_by_code(output['unit'])

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
  def generate_mapping_table_rows(rule)
    formatted_input = input_flattening(rule)
    formatted_input.delete_if { |_, v| v.empty? }
    output = output_formatting(rule)
    #modifier = output['quantity_modifier'] || '+'
    #value = output['modifier_value'] || ''

    input_terms = formatted_input['terms'] || [nil]
    input_units = formatted_input['units'] || [nil]

    output_term_values = slice_values(output['term'], 'term')
    output_unit_values = slice_values(output['unit'], 'unit')

    input_terms_values = []
    input_units_values = []
    rows = []

    input_terms.each do |input_term|
      input_terms_values << slice_values(input_term, 'term')
    end
    input_units.each do |input_unit|
      input_units_values << slice_values(input_unit, 'unit')
    end
    input_values = input_terms_values.product(input_units_values)
    input_values = input_values.map { |v| "#{v[0]},#{v[1]}" }
    input_values.each do |input_codes|
      rows << "(#{input_codes},#{output_term_values},#{output_unit_values})"
    end
    rows
  end

  # TODO This is a draft for a generated WITH AS table
  TRADE_CODE_FIELDS = %w(id code name_en).freeze
  def slice_values(trade_code, code_type)
    return ("NULL," * 3).chop unless trade_code
    return (['EMPTY'] * 3).join(',') if trade_code == 'NULL'

    code_obj = code_type.capitalize.constantize.find_by_code(trade_code)
    code_obj.attributes.slice(*TRADE_CODE_FIELDS).values.join(',')
  end
end
