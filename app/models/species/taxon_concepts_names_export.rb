require 'digest/sha1'
require 'csv'
class Species::TaxonConceptsNamesExport < Species::CsvExport

  def query
    TaxonConcept.select(sql_columns).from(table_name).
      order('name_status, taxonomic_position')
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
      :genus_name, :species_name, :full_name, :author_year, :rank_name, :name_status
    ]
  end

  def csv_column_headers
    headers = [
      'Id', 'Legacy id', 'Kingdom', 'Phylum', 'Class', 'Order', 'Family',
      'Genus', 'Species', 'Scientific Name', 'Author', 'Rank', 'Name status'
    ]
  end

end
