class Species::IucnMappingsExport < Species::CsvCopyExport

  def query
    rel = IucnMapping.from(table_name).
      joins(:taxon_concept).
      joins("LEFT JOIN taxon_concepts AS synonyms ON
            synonym_id = synonyms.id").
      order('taxon_concepts.taxonomic_position, taxon_concepts.full_name')
    rel.select(sql_columns)
  end

private

  def resource_name
    'iucn_mappings'
  end

  def table_name
    'iucn_mappings'
  end

  def sql_columns
    columns = [
      :taxon_concept_id, :"taxon_concepts.data->'class_name'",
      :'taxon_concepts.full_name',
      :'taxon_concepts.author_year', :iucn_taxon_id,
      :iucn_taxon_name, :iucn_author, :iucn_category,
      :"details->'match'", :'synonyms.full_name'
    ]
  end

  def csv_column_headers
    headers = [
      'TaxonConcept id', 'TaxonConcept Class', 'TaxonConcept name',
      'TaxonConcept author', 'IUCN taxon id',
      'IUCN taxon name', 'IUCN taxon author',
      'IUCN category', 'Type of match', 'Synonym (if matched)'
    ]
  end
end
