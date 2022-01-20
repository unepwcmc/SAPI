class Trade::FormattedCodes::TradePlusFormattedFinalCodes < Trade::FormattedCodes::Base

  private

  VIEW_DIR = 'db/views/trade_plus_formatted_data_final_view'.freeze
  def view_dir
    VIEW_DIR
  end

  def codes_map
    @mapping['rules']['standardise_terms_and_units']
  end

  def formatted_query
    attributes = ATTRIBUTES.map { |k, _v| "ts.#{k} AS #{k}" }.join(',')
    group_by_attributes = [ATTRIBUTES.map { |k, _v| "ts.#{k}" }, GROUP_EXTRA_ATTRIBUTES].flatten.join(',')
    <<-SQL
      #{codes_mapping_table}
      SELECT #{attributes},
             -- MAX functions are supposed to to merge rows together based on the join
             -- conditions and replacing NULLs with values from related rows when possible.
             -- Moreover, if ids are -1 or codes/names are 'NULL' strings, replace those with NULL
             -- after the processing is done. This is to get back to just a unique NULL representation.
             NULLIF(COALESCE(MAX(COALESCE(output_term_id, codes_map.term_id)), ts.term_id), '-1')::INTEGER AS term_id,
             NULLIF(COALESCE(MAX(COALESCE(output_term_code, codes_map.term_code)), terms.code), 'NULL') AS term_code,
             NULLIF(COALESCE(MAX(COALESCE(output_term_name, codes_map.term_name)), terms.name_en), 'NULL') AS term_en,
             NULLIF(COALESCE(MAX(COALESCE(output_unit_id, codes_map.unit_id)), ts.unit_id), -1) AS unit_id,
             NULLIF(COALESCE(MAX(COALESCE(output_unit_code, codes_map.unit_code)), units.code), 'NULL') AS unit_code,
             NULLIF(COALESCE(MAX(COALESCE(output_unit_name, codes_map.unit_name)), units.name_en), 'NULL') AS unit_en,
             MAX(COALESCE(codes_map.term_quantity_modifier, ts.term_quantity_modifier)) AS term_quantity_modifier,
             MAX(COALESCE(codes_map.term_modifier_value::FLOAT, ts.term_modifier_value))::FLOAT AS term_modifier_value,
             MAX(COALESCE(codes_map.unit_quantity_modifier, ts.unit_quantity_modifier)) AS unit_quantity_modifier,
             MAX(COALESCE(codes_map.unit_modifier_value::FLOAT, ts.unit_modifier_value))::FLOAT AS unit_modifier_value
        FROM trade_plus_formatted_data_view ts
        #{mapping_join}
        LEFT OUTER JOIN trade_codes terms ON ts.term_id = terms.id
        LEFT OUTER JOIN trade_codes units ON ts.unit_id = units.id
        GROUP BY #{group_by_attributes}
    SQL
  end

  # Joins with bespoke mapping table listing all possible join conditions
  def mapping_join
    <<-SQL
      LEFT OUTER JOIN codes_map ON (
        (
          codes_map.term_id = ts.term_id AND
          (codes_map.unit_id = ts.unit_id OR codes_map.unit_id = -1 AND ts.unit_id IS NULL) AND
          codes_map.taxa_field IS NULL
        ) OR
        (
          codes_map.term_id = ts.term_id AND
          codes_map.unit_id IS NULL AND
          codes_map.taxa_field IS NULL
        ) OR
        (
          (codes_map.unit_id = ts.unit_id OR codes_map.unit_id = -1 AND ts.unit_id IS NULL) AND
          codes_map.term_id IS NULL AND
          codes_map.taxa_field IS NULL
        )
      )
    SQL
  end
end
