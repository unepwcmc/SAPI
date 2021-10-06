class Trade::FormattedCodes::Base

  def initialize
    @mapping = YAML.load_file("#{Rails.root}/lib/data/trade_mapping.yml")
    @query = formatted_query
  end

  def generate_view(timestamp)
    Dir.mkdir(view_dir) unless Dir.exists?(view_dir)
    File.open("#{view_dir}/#{timestamp}.sql", 'w') { |f| f.write(@query) }
  end

  private

  def view_dir
    raise NotImplementedError
  end

  # Generate WITH AS table containing all possible mappings.
  MAPPING_COLUMNS = %w(
    term_id term_code term_name
    unit_id unit_code unit_name
    output_term_id output_term_code output_term_name
    output_unit_id output_unit_code output_unit_name
    taxa_field term_quantity_modifier term_modifier_value
    unit_quantity_modifier unit_modifier_value
  ).freeze
  def codes_mapping_table
    rows = []
    codes_map.each do |rule|
      rows.concat generate_mapping_table_rows(rule)
    end

    <<-SQL
      WITH codes_map(#{MAPPING_COLUMNS.join(',')}) AS (
        VALUES #{rows.join(",\n")}
      )
    SQL
  end

  def codes_map
    raise NotImplementedError
  end

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
    group_name_en: 'ts.group_en',
    group_name_es: 'ts.group_es',
    group_name_fr: 'ts.group_fr',
    quantity: 'ts.quantity',
    exporter_id: 'exporters.id',
    exporter_iso: 'exporters.iso_code2',
    exporter_en: 'exporters.name_en',
    exporter_es: 'exporters.name_es',
    exporter_fr: 'exporters.name_fr',
    importer_id: 'importers.id',
    importer_iso: 'importers.iso_code2',
    importer_en: 'importers.name_en',
    importer_es: 'importers.name_es',
    importer_fr: 'importers.name_fr',
    origin_id: 'origins.id',
    origin_iso: 'origins.iso_code2',
    origin_en: 'origins.name_en',
    origin_es: 'origins.name_es',
    origin_fr: 'origins.name_fr',
    purpose_id: 'purposes.id',
    purpose_en: 'purposes.name_en',
    purpose_es: 'purposes.name_es',
    purpose_fr: 'purposes.name_fr',
    purpose_code: 'purposes.code',
    source_id: 'sources.id',
    source_en: 'sources.name_en',
    source_es: 'sources.name_es',
    source_fr: 'sources.name_fr',
    source_code: 'sources.code',
    rank_id: 'ranks.id',
    rank_name_en: 'ranks.display_name_en',
    rank_name_es: 'ranks.display_name_es',
    rank_name_fr: 'ranks.display_name_fr'
  }.freeze
  GROUP_EXTRA_ATTRIBUTES = %w(
    quantity ts.term_id terms.code terms.name_en terms.name_es terms.name_fr ts.unit_id units.code units.name_en units.name_es units.name_fr
  ).freeze

  def formatted_query
    raise NotImplementedError
  end

  def mapping_join
    raise NotImplementedError
  end

  def input_flattening(rule)
    input = rule['input']
    input.each_with_object({}) do |(k, v), h|
      v.is_a?(Hash) ? v.map { |key, value| h[key] = value } : h[k] = v
    end
  end

  def format_taxa_fields(taxa_fields)
    return 'NULL' unless taxa_fields.present?

    taxa_fields.keys.map do |key|
      next unless taxa_fields[key].is_a?(Array)
      taxa_fields[key] = taxa_fields[key].join(',')
    end
    "'#{taxa_fields.to_s.gsub(/=>/,':')}'::JSON"
  end

  TAXONOMY_FIELDS = %w(kingdom phylum order class family genus group taxa).freeze
  TRADE_CODE_FIELDS = %w(id code name_en).freeze
  def slice_values(trade_code, code_type)
    return ("NULL," * 3).chop unless trade_code
    # When code value is 'NULL' it means that this is
    # an actual condition to be met for the mapping.
    # This is why the id is -1 instead of NULL.
    # Normal NULL values are used to described that there has been
    # no indication for any condition with regard that code/item.
    return [-1, "'NULL'", "'NULL'"].join(',') if trade_code == 'NULL'

    code_obj = code_type.capitalize.constantize.find_by_code(trade_code)
    code_obj.attributes.slice(*TRADE_CODE_FIELDS).values.map do |v|
      v.is_a?(String) ? "'#{v}'" : v
    end.join(',')
  end

  def generate_mapping_table_rows(rule)
    formatted_input = input_flattening(rule)
    formatted_input.delete_if { |_, v| v.empty? }
    output = rule['output']
    modifier = output['quantity_modifier'] ? "'#{output['quantity_modifier']}'" : 'NULL'
    value = output['modifier_value'] ? output['modifier_value'].to_f : 'NULL'

    input_terms = formatted_input['terms'] || [nil]
    input_units = formatted_input['units'] || [nil]
    input_taxa_fields = format_taxa_fields(formatted_input.slice(*TAXONOMY_FIELDS))

    output_term_values = slice_values(output['term'], 'term')
    output_unit_values = slice_values(output['unit'], 'unit')
    output_codes = "#{output_term_values},#{output_unit_values}"

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
      next unless input_unit
      modifier_values = ['NULL', 'NULL', modifier, value].join(',')
    end
    input_values = input_terms_values.product(input_units_values)
    input_values = input_values.map { |v| "#{v[0]},#{v[1]}" }

    input_values.each do |input_codes|
      rows << "(#{input_codes},#{output_codes},#{input_taxa_fields},#{modifier_values})"
    end
    rows
  end
end
