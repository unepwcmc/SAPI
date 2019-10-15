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

  GROUP_MAPPING = {
    'Class'=> 'taxon_concept_class_name',
    'Genus'=> 'taxon_concept_genus_name',
    'Taxon'=> 'taxon_concept_full_name'
  }.freeze
  # TODO refactor creating a separate view for Groups only
  def self.add_group_mapping
    @mapping = YAML.load_file("#{Rails.root}/lib/data/trade_mapping.yml")
    query = []
    map = @mapping['rules']['add_group']
    map.each do |rule|
      rank = GROUP_MAPPING[rule['input']['rank']]
      values  = rule['input']['taxa'].join(',')
      group = rule['output']['group']
      query << "\n\t\t\t\t WHEN #{rank} IN (#{values.to_s}) THEN #{group}\n"
    end
    byebug
    query.join(' ') + 'END'
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
    'units'=> 'units.code'
  }.freeze
  def self.standard_terms
    @mapping = YAML.load_file("#{Rails.root}/lib/data/trade_mapping.yml")
    map = @mapping['rules']['standardise_terms']
    map.each do |rule|
      query = 'WHEN '
      formatted_input = input_flatting(rule)
      formatted_input.delete_if { |_, v| v.empty? }
      subquery = []
      formatted_input.each do |input|
        values = Array(input.second)
        subquery << "#{TERM_MAPPING[input.first]} IN (#{values.join(',')})"
      end
      query += subquery.join(' AND ')
      # byebug
      query += "\n\t\t\t\t THEN "
      output = output_formatting(rule)
      modifier = output['quantity_modifier'] || '+'
      value = output['modifier_value'] || 0
      output_query = "\n\t\t\t\tCASE WHEN ts.reported_by_exporter IS FALSE THEN Array[#{output.first.second}, ts.quantity#{modifier}#{value}::text, NULL, units.code]
                      ELSE Array[#{output.first.second}, NULL, ts.quantity#{modifier}#{value}::text, units.code]
                      END\n"
      byebug
      query += output_query
    end
  end

  def self.input_flatting(rule)
    input = rule['input']
    input.each_with_object({}) do |(k, v), h|
      if v.is_a? Hash
        v.map { |key, value| h[key] = value }
      else
        h[k] = v
      end
    end
  end

  def self.output_formatting(rule)
    output = rule['output']
    output.select { |k, v| k == 'term' } if output['quantity_modifier'].blank?
  end

  def attributes
    #TODO
  end
end
