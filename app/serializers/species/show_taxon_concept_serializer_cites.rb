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
    Quota.from('api_cites_quotas_view trade_restrictions').
      where("
            trade_restrictions.taxon_concept_id = ?
            OR (
              (trade_restrictions.taxon_concept_id IN (?) OR trade_restrictions.taxon_concept_id IS NULL)
              AND matching_taxon_concept_ids @> ARRAY[?]::INT[]
            )
      ", object.id, children_and_ancestors, object.id).
      select(<<-SQL
              trade_restrictions.notes,
              trade_restrictions.url,
              trade_restrictions.start_date,
              trade_restrictions.publication_date,
              trade_restrictions.is_current,
              trade_restrictions.geo_entity_id,
              trade_restrictions.unit_id,
              CASE WHEN quota IS NULL THEN 'in prep.' ELSE quota::TEXT END,
              trade_restrictions.public_display,
              trade_restrictions.nomenclature_note_en,
              trade_restrictions.nomenclature_note_fr,
              trade_restrictions.nomenclature_note_es,
              geo_entity_en,
              unit_en,
              CASE
                WHEN taxon_concept->>'rank' = '#{object.rank_name}'
                THEN NULL
                ELSE
                '[Quota for ' || (taxon_concept->>'rank')::TEXT || ' <i>' || (taxon_concept->>'full_name')::TEXT || '</i>]'
              END AS subspecies_info
            SQL
      ).
      order(<<-SQL
              trade_restrictions.start_date DESC,
              geo_entity_en->>'name' ASC, trade_restrictions.notes ASC,
              subspecies_info DESC
            SQL
      ).all
  end

  def cites_suspensions
    CitesSuspension.from('api_cites_suspensions_view trade_restrictions').
      where("
            trade_restrictions.taxon_concept_id = ?
            OR (
              (trade_restrictions.taxon_concept_id IN (?) OR trade_restrictions.taxon_concept_id IS NULL)
              AND matching_taxon_concept_ids @> ARRAY[?]::INT[]
            )
      ", object.id, children_and_ancestors, object.id).
      select(<<-SQL
              trade_restrictions.notes,
              trade_restrictions.start_date,
              trade_restrictions.end_date,
              trade_restrictions.is_current,
              trade_restrictions.geo_entity_id,
              trade_restrictions.start_notification_id,
              trade_restrictions.end_notification_id,
              trade_restrictions.nomenclature_note_en,
              trade_restrictions.nomenclature_note_fr,
              trade_restrictions.nomenclature_note_es,
              trade_restrictions.geo_entity_en,
              trade_restrictions.start_notification,
              CASE
                WHEN taxon_concept->>'rank' = '#{object.rank_name}'
                THEN NULL
                ELSE
                '[Suspension for ' || (taxon_concept->>'rank')::TEXT || ' <i>' || (taxon_concept->>'full_name')::TEXT || '</i>]'
              END AS subspecies_info
            SQL
      ).
      order(<<-SQL
              trade_restrictions.is_current DESC,
              trade_restrictions.start_date DESC, geo_entity_en->>'name' ASC,
              subspecies_info DESC
            SQL
      ).all
  end

  def eu_decisions
    EuDecision.from('api_eu_decisions_view eu_decisions').
      where("
            eu_decisions.taxon_concept_id = ?
            OR (
              eu_decisions.taxon_concept_id IN (?)
              AND eu_decisions.geo_entity_id IN
                (SELECT geo_entity_id FROM distributions WHERE distributions.taxon_concept_id = ?)
            )
      ", object.id, children_and_ancestors, object.id).
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
              eu_decisions.nomenclature_note_en,
              eu_decisions.nomenclature_note_fr,
              eu_decisions.nomenclature_note_es,
              eu_decision_type,
              start_event,
              end_event,
              geo_entity_en,
              taxon_concept,
              term_en,
              source_en,
              CASE
                WHEN (taxon_concept->>'rank')::TEXT = '#{object.rank_name}'
                THEN NULL
                ELSE
                '[' || (taxon_concept->>'rank')::TEXT || ' decision <i>' || (taxon_concept->>'full_name')::TEXT || '</i>]'
              END AS subspecies_info
             SQL
      ).
      order(<<-SQL
            geo_entity_en->>'name' ASC,
            CASE
              WHEN eu_decisions.type = 'EuOpinion'
                THEN eu_decisions.start_date
              WHEN eu_decisions.type = 'EuSuspension'
                THEN (start_event->>'effective_at')::DATE
            END DESC,
            subspecies_info DESC
        SQL
      ).all
  end

  def cites_listing_changes
    rel = MCitesListingChange.from('api_cites_listing_changes_view listing_changes_mview').
      where(
        'listing_changes_mview.taxon_concept_id' => object_and_children
      )
    if object.rank_name == Rank::SPECIES
      rel = rel.
      where(<<-SQL
              taxon_concepts_mview.rank_name = 'SPECIES' OR
              (
                (
                  taxon_concepts_mview.rank_name = 'SUBSPECIES'
                  OR taxon_concepts_mview.rank_name = 'VARIETY'
                )
                AND listing_changes_mview.auto_note_en IS NULL
              )
            SQL
      )
    end
    rel.
      joins(<<-SQL
              INNER JOIN taxon_concepts_mview
                ON taxon_concepts_mview.id = listing_changes_mview.taxon_concept_id
            SQL
      ).
      select(<<-SQL
              listing_changes_mview.is_current,
              listing_changes_mview.species_listing_name,
              listing_changes_mview.party_id,
              listing_changes_mview.party_en->>'name' AS party_full_name_en,
              listing_changes_mview.effective_at,
              listing_changes_mview.full_note_en,
              listing_changes_mview.short_note_en,
              listing_changes_mview.auto_note_en,
              listing_changes_mview.change_type_name,
              listing_changes_mview.hash_full_note_en,
              listing_changes_mview.hash_ann_parent_symbol,
              listing_changes_mview.hash_ann_symbol,
              listing_changes_mview.inclusion_taxon_concept_id,
              listing_changes_mview.inherited_full_note_en,
              listing_changes_mview.inherited_short_note_en,
              listing_changes_mview.nomenclature_note_en,
              listing_changes_mview.nomenclature_note_fr,
              listing_changes_mview.nomenclature_note_es,
              CASE
                WHEN #{object.rank_name == Rank::SPECIES ? 'TRUE' : 'FALSE'} 
                AND taxon_concepts_mview.rank_name = 'SUBSPECIES'
                  THEN '[SUBSPECIES listing <i>' || taxon_concepts_mview.full_name || '</i>]'
                WHEN #{object.rank_name == Rank::SPECIES ? 'TRUE' : 'FALSE'} 
                AND taxon_concepts_mview.rank_name = 'VARIETY'
                  THEN '[VARIETY listing <i>' || taxon_concepts_mview.full_name || '</i>]'
                ELSE NULL
              END AS subspecies_info
           SQL
      ).
      order(<<-SQL
          effective_at DESC,
          change_type_order ASC,
          species_listing_name ASC,
          subspecies_info DESC
        SQL
      ).all
  end

  def eu_listing_changes
    rel = MEuListingChange.from('api_eu_listing_changes_view listing_changes_mview').
      where(
        'listing_changes_mview.taxon_concept_id' => object_and_children
      )
    if object.rank_name == Rank::SPECIES
      rel = rel.where(<<-SQL
              taxon_concepts_mview.rank_name = 'SPECIES' OR
              (
                (
                  taxon_concepts_mview.rank_name = 'SUBSPECIES'
                  OR taxon_concepts_mview.rank_name = 'VARIETY'
                )
                AND listing_changes_mview.auto_note_en IS NULL
              )
            SQL
      )
    end
    rel.joins(<<-SQL
              INNER JOIN taxon_concepts_mview
                ON taxon_concepts_mview.id = listing_changes_mview.taxon_concept_id
            SQL
      ).
      select(<<-SQL
              listing_changes_mview.id,
              listing_changes_mview.is_current,
              listing_changes_mview.species_listing_name,
              listing_changes_mview.party_id,
              listing_changes_mview.party_en->>'name' AS party_full_name_en,
              listing_changes_mview.effective_at,
              listing_changes_mview.full_note_en,
              listing_changes_mview.short_note_en,
              listing_changes_mview.auto_note_en,
              listing_changes_mview.hash_full_note_en,
              listing_changes_mview.hash_ann_parent_symbol,
              listing_changes_mview.hash_ann_symbol,
              listing_changes_mview.inclusion_taxon_concept_id,
              listing_changes_mview.inherited_full_note_en,
              listing_changes_mview.inherited_short_note_en,
              listing_changes_mview.nomenclature_note_en,
              listing_changes_mview.nomenclature_note_fr,
              listing_changes_mview.nomenclature_note_es,
              eu_regulation->>'name' AS event_name,
              eu_regulation->>'url' AS event_url,
              CASE
                WHEN #{object.rank_name == Rank::SPECIES ? 'TRUE' : 'FALSE'}
                AND taxon_concepts_mview.rank_name = 'SUBSPECIES'
                  THEN '[SUBSPECIES listing <i>' || taxon_concepts_mview.full_name || '</i>]'
                WHEN #{object.rank_name == Rank::SPECIES ? 'TRUE' : 'FALSE'}
                AND taxon_concepts_mview.rank_name = 'VARIETY'
                  THEN '[VARIETY listing <i>' || taxon_concepts_mview.full_name || '</i>]'
                ELSE NULL
              END AS subspecies_info
           SQL
      ).
      order(<<-SQL
          effective_at DESC,
          change_type_order ASC,
          species_listing_name ASC,
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
