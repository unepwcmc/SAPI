class Trade::Grouping::TradePlus

  def initialize(attributes, opts={})
    super(attributes, opts)
    @mapping = YAML.load_file("#{Rails.root}/lib/data/trade_mapping.yml")
  end

  def group_query
    columns = @attributes.compact.uniq.join(',')
    <<-SQL
      SELECT #{columns}, COUNT(*) AS cnt
      FROM #{shipments_table}
      WHERE #{@condition}
      GROUP BY #{columns}
      ORDER BY cnt DESC
      #{limit}
    SQL
  end

  # private

  def shipments_table
    'trade_plus_with_taxa_view'
  end

  def self.exemptions
    @mapping = YAML.load_file("#{Rails.root}/lib/data/trade_mapping.yml")
    query = []
    map = @mapping['rules']['exclusions']
    map.each do |exemp|
      byebug
      key = exemp.first == 'appendices' ? 'appendix' : exemp.first.singularize
      query << "\n\t\t\t\t#{key} NOT IN (#{exemp.second.join(',')})\n"
    end
    query.join("\n\t\t\t\tAND\n")
  end

  TERM_MAPPING = {
    'terms'=> 'terms.code',
    'genus'=> 'ts.taxon_concept_genus_name',
    'units'=> 'units.code',
    'taxa'=> 'ts.taxon_concept_full_name',
    'group'=> 'ts.group'
  }.freeze
  def self.standard_trade_codes
    @mapping = YAML.load_file("#{Rails.root}/lib/data/trade_mapping.yml")
    map = @mapping['rules']['standardise_terms'] +
          @mapping['rules']['standardise_units'] +
          @mapping['rules']['standardise_terms_and_units']
    query = ''
    map.each do |rule|
      query += "\n\t\t\t\tWHEN\n"
      formatted_input = input_flatting(rule)
      formatted_input.delete_if { |_, v| v.empty? }
      subquery = []
      formatted_input.each do |input|
        values = Array(input.second)
        subquery << "#{TERM_MAPPING[input.first]} IN (#{values.join(',')})"
      end
      query += subquery.join(' AND ')
      query += "\n\t\t\t\tTHEN "
      output = output_formatting(rule)
      modifier = output['quantity_modifier'] || '+'
      value = output['modifier_value'] || 0
      byebug
      output_query = "\n\t\t\t\tCASE WHEN ts.reported_by_exporter IS FALSE THEN Array[#{output['term'] || 'terms.code'}, ts.quantity#{modifier}#{value}::text, NULL, #{output['unit'] || 'units.code'}]
                      ELSE Array[#{output['term'] || 'terms.code'}, NULL, ts.quantity#{modifier}#{value}::text, #{output['unit'] || 'units.code'}]
                      END\n"
      query += output_query
    end
    query += "\n AS term_imp_exp_unit,"
  end

  def self.input_flatting(rule)
    input = rule['input']
    input.each_with_object({}) do |(k, v), h|
      v.is_a?(Hash) ? v.map { |key, value| h[key] = value } : h[k] = v
    end
  end

  def self.output_formatting(rule)
    output = rule['output']
    output.select { |k, v| ['term', 'unit'].include? k } if output['quantity_modifier'].blank?
    output
  end

  def attributes
    #TODO
  end
end
