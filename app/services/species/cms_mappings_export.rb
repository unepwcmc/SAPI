class Species::CmsMappingsExport < Species::CsvCopyExport
  def query
    CmsMapping.from(table_name).left_joins(:taxon_concept).order(
      'taxon_concepts.name_status, taxon_concepts.taxonomic_position, taxon_concepts.full_name'
    ).select(sql_columns)
  end

private

  def resource_name
    'cms_mappings'
  end

  def table_name
    'cms_mappings'
  end

  def sql_columns
    columns = [
      :taxon_concept_id, :"taxon_concepts.data->'class_name'",
      :'taxon_concepts.full_name', :'taxon_concepts.name_status',
      :'taxon_concepts.author_year',
      :cms_taxon_name, :cms_author, :"details->'distributions_splus'",
      :"details->'distributions_cms'", :"details->'instruments_splus'",
      :"details->'instruments_cms'", :"details->'listing_splus'",
      :"details->'listing_cms'"

    ]
  end

  def csv_column_headers
    headers = [
      'TaxonConcept id', 'TaxonConcept Class', 'TaxonConcept name',
      'TaxonConcept name status', 'TaxonConcept author',
      'CMS taxon name', 'CMS author', 'Distribution S+', 'Distribution CMS',
      'Instruments S+', 'Instruments CMS', 'Listing S+', 'Listing CMS'
    ]
  end
end
