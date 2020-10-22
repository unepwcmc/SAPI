class Species::EuDecisionsExport < Species::CsvCopyExport

  def initialize(filters)
    @filters = filters
    @taxon_concepts_ids = filters[:taxon_concepts_ids]
    @geo_entities_ids = filters[:geo_entities_ids]
    @years = filters[:years]
    @decision_types = filters[:decision_types]
    @eu_decision_filter = filters[:eu_decision_filter]
    @set = filters[:set]
    initialize_csv_separator(filters[:csv_separator])
    initialize_file_name
  end

  HISTORIC_III_OPINIONS = ['(No opinion) iii)','(No opinion) iii) removed'].freeze
  def query
    rel = EuDecision.from("#{table_name} AS eu_decisions").
      select(sql_columns).
      order(:taxonomic_position, :party, :ordering_date)
    return rel.where('srg_history = ?', @eu_decision_filter) if @eu_decision_filter == 'In consultation'
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
        'EXTRACT(YEAR FROM start_date)::INTEGER IN (?)', @years.map(&:to_i)
      )
    end

    # decision_type can now be NULL.
    # With the following condition, Postgresql does not take into account NULL values.
    # Furthemore, the SRG_REFERRAL filter should also include the historic iii) when All
    # filter value is selected
    if excluded_decision_types.present?
      rel =
        if @set == 'all' && !excluded_decision_types.include?('SRG_REFERRAL')
          rel.where("decision_type NOT IN(?) OR decision_type_for_display IN(?)", excluded_decision_types, HISTORIC_III_OPINIONS)
        else
          rel.where('decision_type NOT IN(?)', excluded_decision_types)
        end
    end

    # remove decisions with NULL type 'decision_type IS NOT NULL'
     rel = rel.where('decision_type IS NOT NULL')

    # exclude EU decisions 'Discussed at SRG' by default
    # IS DISTINCT FROM allows to return records with NULL as well
    rel = rel.where('srg_history IS DISTINCT FROM ?', 'Discussed at SRG')
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
      'Full Name', 'Rank', 'Date of Decision', 'Valid since', 'Party',
      'EU Decision', 'SRG History', 'Source', 'Term',
      'Notes', 'Document', "Valid on Date: #{DateTime.now.strftime('%d/%m/%Y')}"
    ]
  end

  def sql_columns
    columns = [
      :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
      :genus_name, :species_name, :subspecies_name,
      :full_name, :rank_name, :start_date_formatted, :original_start_date_formatted, :party,
      :decision_type_for_display, :srg_history, :source_code_and_name, :term_name,
      :full_note_en, :start_event_name, :is_valid_for_display
    ]
  end

  # Produces list of excluded decision types.
  # e.g. SUSPENSIONS,SRG_REFERRAL
  def excluded_decision_types
    @excluded_decision_types ||= @decision_types.map do |key, value|
      value == 'false' ? key.singularize.underscore.upcase : nil
    end.compact
  end
end
