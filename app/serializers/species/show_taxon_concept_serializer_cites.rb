class Species::ShowTaxonConceptSerializerCites < Species::ShowTaxonConceptSerializer

  attributes :cites_listing, :eu_listing
  has_many :quotas, :serializer => Species::QuotaSerializer, :key => :cites_quotas
  has_many :cites_suspensions, :serializer => Species::CitesSuspensionSerializer
  has_many :cites_listing_changes, :serializer => Species::CitesListingChangeSerializer,
    :key => :cites_listings
  has_many :eu_listing_changes, :serializer => Species::EuListingChangeSerializer,
    :key => :eu_listings
  has_many :eu_decisions, :serializer => Species::EuDecisionSerializer

  def quotas
    Quota.joins(:geo_entity).
      where("
            trade_restrictions.taxon_concept_id = ?
            OR (
              (trade_restrictions.taxon_concept_id IN (?) OR trade_restrictions.taxon_concept_id IS NULL)
              AND trade_restrictions.geo_entity_id IN
                (SELECT geo_entity_id FROM distributions WHERE distributions.taxon_concept_id = ?)
            )
      ", object.id, children_and_ancestors, object.id).
      joins('LEFT JOIN taxon_concepts_mview ON taxon_concepts_mview.id = trade_restrictions.taxon_concept_id').
      select(<<-SQL
              trade_restrictions.notes,
              trade_restrictions.url,
              trade_restrictions.start_date,
              trade_restrictions.publication_date,
              trade_restrictions.is_current,
              trade_restrictions.geo_entity_id,
              trade_restrictions.unit_id,
              trade_restrictions.quota,
              trade_restrictions.public_display,
              CASE
                WHEN taxon_concepts_mview.rank_name = 'SPECIES'
                THEN NULL
                ELSE '[Quota for ' || taxon_concepts_mview.rank_name || ' <i>' || taxon_concepts_mview.full_name || '</i>]'
              END AS subspecies_info
             SQL
      ).
      order(<<-SQL
              trade_restrictions.start_date DESC,
              geo_entities.name_en ASC, trade_restrictions.notes ASC,
              subspecies_info DESC
            SQL
      ).all
  end

  def cites_suspensions
    CitesSuspension.joins(:geo_entity).
      where("
            trade_restrictions.taxon_concept_id = ?
            OR (
              (trade_restrictions.taxon_concept_id IN (?) OR trade_restrictions.taxon_concept_id IS NULL)
              AND trade_restrictions.geo_entity_id IN
                (SELECT geo_entity_id FROM distributions WHERE distributions.taxon_concept_id = ?)
            )
      ", object.id, children_and_ancestors, object.id).
      joins(:start_notification).
      joins('LEFT JOIN taxon_concepts_mview ON taxon_concepts_mview.id = trade_restrictions.taxon_concept_id').
      select(<<-SQL
              trade_restrictions.notes,
              trade_restrictions.start_date,
              trade_restrictions.end_date,
              trade_restrictions.is_current,
              trade_restrictions.geo_entity_id,
              trade_restrictions.start_notification_id,
              trade_restrictions.end_notification_id,
              CASE
                WHEN taxon_concepts_mview.rank_name = 'SPECIES'
                THEN NULL
                ELSE '[Suspension for ' || taxon_concepts_mview.rank_name || ' <i>' || taxon_concepts_mview.full_name || '</i>]'
              END AS subspecies_info
             SQL
      ).
      order(<<-SQL
            trade_restrictions.is_current DESC,
            trade_restrictions.start_date DESC, geo_entities.name_en ASC,
            subspecies_info DESC
        SQL
      ).all
  end

  def eu_decisions
    EuDecision.joins([:start_event, :geo_entity]).
      where("
            eu_decisions.taxon_concept_id = ?
            OR (
              eu_decisions.taxon_concept_id IN (?)
              AND eu_decisions.geo_entity_id IN
                (SELECT geo_entity_id FROM distributions WHERE distributions.taxon_concept_id = ?)
            )
      ", object.id, children_and_ancestors, object.id).
      joins('INNER JOIN taxon_concepts_mview ON taxon_concepts_mview.id = eu_decisions.taxon_concept_id').
      select(<<-SQL
              eu_decisions.notes,
              eu_decisions.start_date,
              eu_decisions.is_current,
              eu_decisions.geo_entity_id,
              eu_decisions.start_event_id,
              eu_decisions.term_id,
              eu_decisions.source_id,
              eu_decisions.eu_decision_type_id,
              eu_decisions.term_id,
              eu_decisions.source_id,
              CASE
                WHEN taxon_concepts_mview.rank_name = 'SPECIES'
                THEN NULL
                ELSE '[' || taxon_concepts_mview.rank_name || ' decision <i>' || taxon_concepts_mview.full_name || '</i>]'
              END AS subspecies_info
             SQL
      ).
      order(<<-SQL
            geo_entities.name_en ASC, eu_decisions.start_date DESC,
            subspecies_info DESC
        SQL
      ).all
  end

  def cites_listing_changes
    cites = Designation.find_by_name(Designation::CITES)
    MListingChange.
      where(:taxon_concept_id => object_and_children, :show_in_history => true, :designation_id => cites && cites.id).
      where(<<-SQL
              taxon_concepts_mview.rank_name = 'SPECIES' OR 
              ( 
                (
                  taxon_concepts_mview.rank_name = 'SUBSPECIES'
                  OR taxon_concepts_mview.rank_name = 'VARIETY'
                )
                AND listing_changes_mview.auto_note IS NULL
              )
            SQL
      ).
      joins(<<-SQL
              INNER JOIN taxon_concepts_mview
                ON taxon_concepts_mview.id = listing_changes_mview.taxon_concept_id
            SQL
      ).
      select(<<-SQL
              CASE
                WHEN listing_changes_mview.change_type_name = 'DELETION'
                  OR listing_changes_mview.change_type_name = 'RESERVATION_WITHDRAWAL'
                  THEN 'f'
                ELSE listing_changes_mview.is_current
              END AS is_current,
              listing_changes_mview.species_listing_name,
              listing_changes_mview.party_id,
              listing_changes_mview.effective_at,
              listing_changes_mview.full_note_en,
              listing_changes_mview.short_note_en,
              listing_changes_mview.auto_note,
              listing_changes_mview.change_type_name,
              listing_changes_mview.hash_full_note_en,
              listing_changes_mview.hash_ann_parent_symbol,
              listing_changes_mview.hash_ann_symbol,
              listing_changes_mview.inclusion_taxon_concept_id,
              listing_changes_mview.inherited_full_note_en,
              listing_changes_mview.inherited_short_note_en,
              CASE
                WHEN taxon_concepts_mview.rank_name = 'SUBSPECIES'
                  THEN '[SUBSPECIES listing <i>' || taxon_concepts_mview.full_name || '</i>]'
                WHEN taxon_concepts_mview.rank_name = 'VARIETY'
                  THEN '[VARIETY listing <i>' || taxon_concepts_mview.full_name || '</i>]'
                ELSE NULL
              END AS subspecies_info
           SQL
      ).
      order(<<-SQL
          effective_at DESC,
          CASE
            WHEN change_type_name = 'ADDITION' THEN 0
            WHEN change_type_name = 'RESERVATION' THEN 1
            WHEN change_type_name = 'RESERVATION_WITHDRAWAL' THEN 2
            WHEN change_type_name = 'DELETION' THEN 3
          END,
          subspecies_info DESC
        SQL
      ).all
  end

  def eu_listing_changes
    eu = Designation.find_by_name(Designation::EU)
    MListingChange.
      where(:taxon_concept_id => object_and_children, :show_in_history => true, :designation_id => eu && eu.id).
      where(<<-SQL
              taxon_concepts_mview.rank_name = 'SPECIES' OR 
              ( taxon_concepts_mview.rank_name = 'SUBSPECIES' AND
                listing_changes_mview.auto_note IS NULL )
            SQL
      ).
      joins(<<-SQL
              INNER JOIN taxon_concepts_mview
                ON taxon_concepts_mview.id = listing_changes_mview.taxon_concept_id
              INNER JOIN listing_changes
                ON listing_changes.id = listing_changes_mview.id
              INNER JOIN events
                ON events.id = listing_changes.event_id
            SQL
      ).
      select(<<-SQL
              listing_changes_mview.id,
              listing_changes_mview.is_current,
              listing_changes_mview.species_listing_name,
              listing_changes_mview.party_id,
              listing_changes_mview.effective_at,
              listing_changes_mview.full_note_en,
              listing_changes_mview.short_note_en,
              listing_changes_mview.auto_note,
              listing_changes_mview.hash_full_note_en,
              listing_changes_mview.hash_ann_parent_symbol,
              listing_changes_mview.hash_ann_symbol,
              listing_changes_mview.inclusion_taxon_concept_id,
              listing_changes_mview.inherited_full_note_en,
              listing_changes_mview.inherited_short_note_en,
              events.description AS event_name,
              events.url AS event_url,
              CASE
                WHEN taxon_concepts_mview.rank_name = 'SUBSPECIES'
                  THEN '[SUBSPECIES listing <i>' || taxon_concepts_mview.full_name || '</i>]'
                ELSE NULL
              END AS subspecies_info
           SQL
      ).
      order(<<-SQL
          effective_at DESC,
          CASE
            WHEN change_type_name = 'ADDITION' THEN 3
            WHEN change_type_name = 'RESERVATION' THEN 2
            WHEN change_type_name = 'RESERVATION_WITHDRAWAL' THEN 1
            WHEN change_type_name = 'DELETION' THEN 0
          END,
          subspecies_info DESC
        SQL
      ).all
  end


  def cites_listing
    object.listing && object.listing['cites_listing']
  end

  def eu_listing
    object.listing && object.listing['eu_listing']
  end

end
