require 'digest/sha1'
require 'csv'
class Species::TaxonConceptsNamesExport < Species::CsvExport

  def initialize(filters)
    @filters = filters || {}
    @taxonomy = @filters[:taxonomy] && Taxonomy.find_by_name(filters[:taxonomy])
  end

  def query
    rel = TaxonConcept.select(sql_columns).from(table_name).
      order('name_status, taxonomic_position')
    rel = rel.where("#{table_name}.taxonomy_id" => @taxonomy.id) if @taxonomy
    rel
  end

private

  def resource_name
    'taxon_concepts_names'
  end

  def table_name
    'taxon_concepts_names_view'
  end

  def sql_columns
    columns = [
      :id, :legacy_id, :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
      :genus_name, :species_name, :full_name, :author_year, :rank_name, :name_status, :taxonomy_name
    ]
  end

  def csv_column_headers
    headers = [
      'Id', 'Legacy id', 'Kingdom', 'Phylum', 'Class', 'Order', 'Family',
      'Genus', 'Species', 'Scientific Name', 'Author', 'Rank', 'Name status', 'Taxonomy'
    ]
  end

end
