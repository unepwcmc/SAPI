class Species::EuDecisionsExport < Species::CsvCopyExport

  def initialize(filters)
    @filters = filters
    @taxon_concepts_ids = filters[:taxon_concepts_ids]
    @geo_entities_ids = filters[:geo_entities_ids]
    @years = filters[:years]
    @decision_types = filters[:decision_types]
    @set = filters[:set]
    initialize_csv_separator(filters[:csv_separator])
    initialize_file_name
  end

  def query
    rel = EuDecision.from("#{table_name} AS eu_decisions").
      select(sql_columns).
      order(:taxonomic_position, :party, :ordering_date)
    if @set == 'current'
      rel = rel.where(is_valid: true)
    end
    unless @geo_entities_ids.nil? || @geo_entities_ids.empty?
      geo_entities_ids = GeoEntity.nodes_and_descendants(
        @geo_entities_ids
      ).map(&:id)
      rel = rel.where(:geo_entity_id => geo_entities_ids)
    end
    unless @taxon_concepts_ids.nil? || @taxon_concepts_ids.empty?
      conds_str = <<-SQL
        ARRAY[
          taxon_concept_id, family_id, order_id, class_id,
          phylum_id, kingdom_id
        ] && ARRAY[?]
        OR taxon_concept_id IS NULL
      SQL
      rel = rel.where(conds_str, @taxon_concepts_ids.map(&:to_i))
    end
    unless @years.nil? || @years.empty?
      rel = rel.where(
        'EXTRACT(YEAR FROM start_date) IN (?)', @years
      )
    end
    if @decision_types['negativeOpinions'] == 'false'
      rel = rel.where('decision_type <> ?', EuDecisionType::NEGATIVE_OPINION)
    end
    if @decision_types['positiveOpinions'] == 'false'
      rel = rel.where('decision_type <> ?', EuDecisionType::POSITIVE_OPINION)
    end
    if @decision_types['noOpinions'] == 'false'
      rel = rel.where('decision_type <> ?', EuDecisionType::NO_OPINION)
    end
    if @decision_types['suspensions'] == 'false'
      rel = rel.where('decision_type <> ?', EuDecisionType::SUSPENSION)
    end
    rel
  end

  private

  def resource_name
    'eu_decisions'
  end

  def table_name
    'eu_decisions_view'
  end

  def csv_column_headers
    headers = [
      'Kingdom', 'Phylum', 'Class', 'Order', 'Family',
      'Genus', 'Species', 'Subspecies',
      'Full Name', 'Rank', 'Date of Decision',  'Valid since', 'Party',
      'EU Decision', 'Source',  'Term',
      'Notes', 'Document',  "Valid on Date: #{DateTime.now.strftime('%d/%m/%Y')}"
    ]
  end

  def sql_columns
    columns = [
      :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
      :genus_name, :species_name, :subspecies_name,
      :full_name, :rank_name, :start_date_formatted, :original_start_date_formatted, :party,
      :decision_type_for_display, :source_code_and_name, :term_name,
      :full_note_en, :start_event_name, :is_valid_for_display
    ]
  end

end
