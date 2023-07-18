class Species::CitesProcessesExport < Species::CsvCopyExport

  def query
    rel = CitesProcess
          .joins("LEFT JOIN taxon_concepts ON taxon_concept_id = taxon_concepts.id
                  LEFT JOIN geo_entities ON geo_entity_id = geo_entities.id
                  LEFT JOIN events ON start_event_id = events.id")
    rel = apply_filters(rel)
    rel = rel.order('taxon_concepts.full_name','cites_processes.type DESC','geo_entities.name_en')

    rel.select(sql_columns)
  end

  private

  def apply_filters(rel)
    rel = rel.where(resolution: resolution) unless @filters['process_type'] == 'Both'
    rel = rel.where("DATE_PART('YEAR', start_date) IN (?)", @filters['years']) if @filters['years']&.any?
    rel = rel.where("status != 'Closed'") if @filters['set'] == 'current'
    rel = rel.where('geo_entities.id IN (?)', geo_entities_ids) if @filters['geo_entities_ids']&.any?

    # Query 'data' json field for taxon concepts that have the submitted taxon_concept_id in their ancestry,
    # or are the taxon_concept indicated by the txon_concept_id.
    if @filters['taxon_concepts_ids']&.any?
      taxon_concept = TaxonConcept.find(@filters['taxon_concepts_ids'].first)
      rel = rel.where("taxon_concepts.data -> :rank_id_key = :taxon_concept_id OR taxon_concept_id = :taxon_concept_id",
                      rank_id_key: "#{taxon_concept.rank.name.downcase}_id", taxon_concept_id: taxon_concept.id.to_s)
    end

    rel
  end

  def geo_entities_ids
    GeoEntity.nodes_and_descendants(@filters['geo_entities_ids']).pluck(:id)
  end

  def resolution
    case @filters['process_type']
    when 'Rst'
      ['Significant Trade']
    when 'CaptiveBreeding'
      ['Captive Breeding']
    else
      ['Significant Trade', 'Captive Breeding']
    end
  end

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
