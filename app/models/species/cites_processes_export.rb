class Species::CitesProcessesExport < Species::CsvCopyExport

  def query
    rel = CitesProcess.joins("LEFT JOIN taxon_concepts ON
            taxon_concept_id = taxon_concepts.id LEFT JOIN geo_entities ON
            geo_entity_id = geo_entities.id LEFT JOIN events ON
            start_event_id = events.id").order('taxon_concepts.id','cites_processes.id')
    rel.select(sql_columns)
  end

  private

  def resource_name
    'cites_processes'
  end

  def table_name
    'cites_processes'
  end

  def sql_columns
    [
      :'cites_processes.id', :taxon_concept_id, :'taxon_concepts.full_name',
      :resolution, :'geo_entities.name_en', :'events.name', "to_char(start_date, 'DD/MM/YYYY')",
      :status, :'cites_processes.document', :'cites_processes.notes'
    ]
  end

  def csv_column_headers
    [
      'Id', 'TaxonConcept id', 'TaxonConcept name', 'Resolution', 'Country', 'Event',
      'Event date', 'Status', 'Document', 'Notes'
    ]
  end

end