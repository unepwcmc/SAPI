class Species::TaxonConceptsNamesExport < Species::CsvCopyExport

  def query
    rel = TaxonConcept.from(table_name).
      order('name_status, taxonomic_position')
    rel = rel.where("#{table_name}.taxonomy_id" => @taxonomy.id) if @taxonomy
    rel.select(sql_columns)
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
      :genus_name, :species_name, :full_name, :author_year, :rank_name, :name_status,
      :taxonomy_name, :created_at, :created_by
    ]
  end

  def csv_column_headers
    headers = [
      'Id', 'Legacy id', 'Kingdom', 'Phylum', 'Class', 'Order', 'Family',
      'Genus', 'Species', 'Scientific Name', 'Author', 'Rank', 'Name status',
      'Taxonomy', 'Date added', 'Added by'
    ]
  end

end
