class Species::TaxonConceptsDistributionsExport < Species::CsvCopyExport

  def query
    rel = TaxonConcept.from(table_name).
      order('taxonomic_position, geo_entity_name')
    rel = rel.where("#{table_name}.taxonomy_id" => @taxonomy.id) if @taxonomy
    rel.select(sql_columns)
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
      :reference_legacy_id, :taxonomy_name, :internal_notes,
      :created_at, :created_by, :updated_at, :updated_by
    ]
  end

  def csv_column_headers
    headers = [
      'Id', 'Legacy Id', 'Phylum', 'Class', 'Order', 'Family',
      'Scientific Name', 'Rank', 'Geo_entity', 'Country_full',
      'ISO Code', 'Country Tags', 'Reference_full', 'Reference IDS',
      'Ref Legacy ID', 'Taxonomy', 'Internal notes',
      'Date added', 'Added by', 'Date updated', 'Updated by'
    ]
  end

end
