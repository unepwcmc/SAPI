class Species::OrphanedTaxonConceptsExport < Species::CsvCopyExport

  def query
    rel = TaxonConcept.from(table_name).
      order('full_name')
    rel = rel.where("#{table_name}.taxonomy_id" => @taxonomy.id) if @taxonomy
    rel.select(sql_columns)
  end

private

  def resource_name
    'orphaned_taxon_concepts'
  end

  def table_name
    'orphaned_taxon_concepts_view'
  end

  def sql_columns
    columns = [
      :id, :legacy_id, :full_name, :author_year, :rank_name, :name_status,
      :taxonomy_name, :internal_notes,
      :created_at, :created_by, :updated_at, :dependents_updated_at, :updated_by
    ]
  end

  def csv_column_headers
    headers = [
      'Id', 'Legacy id', 'Scientific Name', 'Author', 'Rank', 'Name status',
      'Taxonomy', 'Internal notes',
      'Date added', 'Added by', 'Taxon Concept updated date',
      'Taxon Concept associations updated date', 'Updated by'
    ]
  end

end
