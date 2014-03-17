require 'digest/sha1'
require 'csv'
class Species::TaxonConceptsDistributionsExport < Species::CsvExport

  def initialize(filters)
    @filters = filters || {}
    @taxonomy = @filters[:taxonomy] && Taxonomy.find_by_name(filters[:taxonomy])
  end

  def query
    rel = TaxonConcept.select(sql_columns).from(table_name).
      order('taxonomic_position, geo_entity_name')
    rel = rel.where("#{table_name}.taxonomy_id" => @taxonomy.id) if @taxonomy
    rel
  end

private

  def resource_name
    'taxon_concepts_distributions'
  end

  def table_name
    'taxon_concepts_distributions_view'
  end

  def sql_columns
    columns = [
      :id, :legacy_id, :phylum_name, :class_name, :order_name, :family_name,
      :full_name, :rank_name, :geo_entity_type, :geo_entity_name,
      :geo_entity_iso_code2, :tags, :reference_full, :reference_id,
      :reference_legacy_id, :taxonomy_name
    ]
  end

  def csv_column_headers
    headers = [
      'Id', 'Legacy Id', 'Phylum', 'Class', 'Order', 'Family',
      'Scientific Name', 'Rank', 'Geo_entity', 'Country_full',
      'ISO Code', 'Country Tags', 'Reference_full', 'Reference IDS',
      'Ref Legacy ID', 'Taxonomy'
    ]
  end

end
