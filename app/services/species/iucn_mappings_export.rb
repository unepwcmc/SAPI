class Species::IucnMappingsExport < Species::CsvCopyExport
  def query
    IucnMapping.from(
      table_name
    ).joins(
      :taxon_concept
    ).left_joins(
      [ :accepted_names ]
    ).order(
      'taxon_concepts.name_status, taxon_concepts.taxonomic_position, taxon_concepts.full_name'
    ).select(sql_columns)
  end

private

  def resource_name
    'iucn_mappings'
  end

  def table_name
    'iucn_mappings'
  end

  def sql_columns
    [
      :taxon_concept_id, :"taxon_concepts.data->'class_name'",
      :'taxon_concepts.full_name', :'taxon_concepts.name_status',
      :'taxon_concepts.author_year', :iucn_taxon_id,
      :iucn_taxon_name, :iucn_author, :iucn_category,
      :"details->'match'", :'accepted_names.full_name', :accepted_name_id
    ]
  end

  def csv_column_headers
    [
      'TaxonConcept id', 'TaxonConcept Class', 'TaxonConcept name',
      'TaxonConcept name status', 'TaxonConcept author', 'IUCN taxon id',
      'IUCN taxon name', 'IUCN taxon author',
      'IUCN category', 'Type of match', 'Accepted Name (if matched on synonym)',
      'Accepted Name ID'
    ]
  end
end
