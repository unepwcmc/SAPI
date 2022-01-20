class Trade::FormattedCodes::TradePlusFormattedCodes < Trade::FormattedCodes::Base

  private

  VIEW_DIR = 'db/views/trade_plus_formatted_data_view'.freeze
  def view_dir
    VIEW_DIR
  end

  def codes_map
    @mapping['rules']['standardise_terms'] + @mapping['rules']['standardise_units']
  end

  def formatted_query
    attributes = ATTRIBUTES.map { |k, v| "#{v} AS #{k}" }.join(',')
    group_by_attributes = [ATTRIBUTES.values, GROUP_EXTRA_ATTRIBUTES].flatten.join(',')
    <<-SQL
      #{codes_mapping_table}
      SELECT #{attributes},
             -- MAX functions are supposed to to merge rows together based on the join
             -- conditions and replacing NULLs with values from related rows when possible.
             -- Moreover, if ids are -1 or codes/names are 'NULL' strings, replace those with NULL
             -- after the processing is done. This is to get back to just a unique NULL representation.
             NULLIF(COALESCE(MAX(COALESCE(output_term_id, codes_map.term_id)), ts.term_id), -1) AS term_id,
             NULLIF(COALESCE(MAX(COALESCE(output_term_code, codes_map.term_code)), terms.code), 'NULL') AS term_code,
             NULLIF(COALESCE(MAX(COALESCE(output_term_name, codes_map.term_name)), terms.name_en), 'NULL') AS term_en,
             NULLIF(COALESCE(MAX(COALESCE(output_unit_id, codes_map.unit_id)), ts.unit_id), -1) AS unit_id,
             NULLIF(COALESCE(MAX(COALESCE(output_unit_code, codes_map.unit_code)), units.code), 'NULL') AS unit_code,
             NULLIF(COALESCE(MAX(COALESCE(output_unit_name, codes_map.unit_name)), units.name_en), 'NULL') AS unit_en,
             MAX(term_quantity_modifier) AS term_quantity_modifier,
             MAX(term_modifier_value)::FLOAT AS term_modifier_value,
             MAX(unit_quantity_modifier) AS unit_quantity_modifier,
             MAX(unit_modifier_value)::FLOAT AS unit_modifier_value
        FROM trade_plus_group_view ts
        #{mapping_join}
        LEFT OUTER JOIN trade_codes terms ON ts.term_id = terms.id
        LEFT OUTER JOIN trade_codes units ON ts.unit_id = units.id
        LEFT OUTER JOIN trade_codes sources ON ts.source_id = sources.id
        LEFT OUTER JOIN trade_codes purposes ON ts.purpose_id = purposes.id
        INNER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
        LEFT OUTER JOIN geo_entities exporters ON ts.china_exporter_id = exporters.id
        LEFT OUTER JOIN geo_entities importers ON ts.china_importer_id = importers.id
        LEFT OUTER JOIN geo_entities origins ON ts.china_origin_id = origins.id
        WHERE #{exemptions}
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
          #{taxa_join_condition}
        ) OR
        (
          codes_map.term_id = ts.term_id AND
          (codes_map.unit_id = ts.unit_id OR codes_map.unit_id = -1 AND ts.unit_id IS NULL) AND
          codes_map.taxa_field IS NULL
        ) OR
        (
          codes_map.term_id = ts.term_id AND codes_map.unit_id IS NULL AND
          #{taxa_join_condition}
        ) OR
        (
          (codes_map.unit_id = ts.unit_id OR codes_map.unit_id = -1 AND ts.unit_id IS NULL) AND
           codes_map.term_id IS NULL AND
           #{taxa_join_condition}
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
        ) OR
        (
          codes_map.term_id IS NULL AND
          codes_map.unit_id IS NULL AND
          #{taxa_join_condition}
        )
      )
    SQL
  end

  def taxa_join_condition
    <<-SQL
      (
        ts.taxon_concept_kingdom_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'kingdom', ',')) OR
        ts.taxon_concept_phylum_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'phylum', ',')) OR
        ts.taxon_concept_class_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'class', ',')) OR
        ts.taxon_concept_order_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'order', ',')) OR
        ts.taxon_concept_family_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'family', ',')) OR
        ts.taxon_concept_genus_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'genus', ',')) OR
        ts.taxon_concept_full_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'taxa', ',')) OR
        ts.group_en = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'group', ','))
      )
    SQL
  end

  TERM_MAPPING = {
    'terms'=> 'ts.term_id',
    'genus'=> 'ts.taxon_concept_genus_name',
    'units'=> 'ts.unit_id',
    'taxa'=> 'ts.taxon_concept_full_name',
    'group'=> 'ts.group_en',
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
end
