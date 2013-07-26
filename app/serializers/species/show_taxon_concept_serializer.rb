class Species::ShowTaxonConceptSerializer < ActiveModel::Serializer
  cached
  root 'taxon_concept'
  attributes :id, :full_name, :author_year, :standard_references,
    :common_names, :distributions, :subspecies, :distribution_references,
    :taxonomy

  has_many :synonyms, :serializer => Species::SynonymSerializer
  has_one :m_taxon_concept, :serializer => Species::MTaxonConceptSerializer
  has_many :taxon_concept_references, :serializer => Species::ReferenceSerializer,
    :key => :references
  has_many :quotas, :serializer => Species::QuotaSerializer, :key => :cites_quotas
  has_many :cites_suspensions, :serializer => Species::CitesSuspensionSerializer
  has_many :cites_listing_changes, :serializer => Species::CitesListingChangeSerializer,
    :key => :cites_listings
  has_many :eu_listing_changes, :serializer => Species::EuListingChangeSerializer,
    :key => :eu_listings

  def taxonomy
    object.taxonomy.name.downcase
  end

  def synonyms
    object.synonyms.
      order("full_name")
  end

  def object_and_children
    [object.id]+object.children.select(:id).map(&:id)
  end

  def quotas
    Quota.where(:taxon_concept_id => object_and_children).joins(:geo_entity).
      includes([:unit, :geo_entity => :geo_entity_type]).
      joins('INNER JOIN taxon_concepts_mview ON taxon_concepts_mview.id = trade_restrictions.taxon_concept_id').
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
                WHEN taxon_concepts_mview.rank_name = 'SUBSPECIES'
                  THEN '[Quota for SUBSPECIES ' || taxon_concepts_mview.full_name || ']'
                ELSE NULL
              END AS subspecies_info
             SQL
      ).
      order(<<-SQL
              geo_entities.name_en ASC, trade_restrictions.notes ASC,
              subspecies_info DESC
            SQL
      )
  end

  def cites_suspensions
    CitesSuspension.where(:taxon_concept_id => object_and_children).
      joins([:start_notification, :geo_entity]).
      joins('INNER JOIN taxon_concepts_mview ON taxon_concepts_mview.id = trade_restrictions.taxon_concept_id').
      select(<<-SQL
              trade_restrictions.notes,
              trade_restrictions.start_date,
              trade_restrictions.end_date,
              trade_restrictions.is_current,
              trade_restrictions.geo_entity_id,
              trade_restrictions.start_notification_id,
              trade_restrictions.end_notification_id,
              CASE
                WHEN taxon_concepts_mview.rank_name = 'SUBSPECIES'
                  THEN '[Suspension for SUBSPECIES ' || taxon_concepts_mview.full_name || ']'
                ELSE NULL
              END AS subspecies_info
             SQL
      ).
      order(<<-SQL
            trade_restrictions.is_current DESC,
            events.effective_at DESC, geo_entities.name_en ASC,
            subspecies_info DESC
        SQL
      )
  end

  def cites_listing_changes
    cites = Designation.find_by_name(Designation::CITES)
    MListingChange.
      where(:taxon_concept_id => object_and_children, :show_in_history => true, :designation_id => cites && cites.id).
      where(<<-SQL
              taxon_concepts_mview.rank_name = 'SPECIES' OR 
              ( taxon_concepts_mview.rank_name = 'SUBSPECIES' AND
                listing_changes_mview.auto_note IS NULL )
            SQL
      ).
      joins(<<-SQL
              INNER JOIN taxon_concepts_mview
                ON taxon_concepts_mview.id = listing_changes_mview.taxon_concept_id 
            SQL
      ).
      select(<<-SQL
              listing_changes_mview.is_current,
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
              CASE
                WHEN taxon_concepts_mview.rank_name = 'SUBSPECIES'
                  THEN '[Listing for SUBSPECIES ' || taxon_concepts_mview.full_name || ']'
                ELSE NULL
              END AS subspecies_info
           SQL
      ).
      order(<<-SQL
          is_current DESC,
          effective_at DESC,
          CASE
            WHEN change_type_name = 'ADDITION' THEN 3
            WHEN change_type_name = 'RESERVATION' THEN 2
            WHEN change_type_name = 'RESERVATION_WITHDRAWAL' THEN 1
            WHEN change_type_name = 'DELETION' THEN 0
          END,
          subspecies_info DESC
        SQL
      )
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
              listing_changes_mview.hash_full_note_en,
              listing_changes_mview.hash_ann_parent_symbol,
              listing_changes_mview.hash_ann_symbol,
              events.description AS event_name,
              CASE
                WHEN taxon_concepts_mview.rank_name = 'SUBSPECIES'
                  THEN '[Listing for SUBSPECIES ' || taxon_concepts_mview.full_name || ']'
                ELSE NULL
              END AS subspecies_info
           SQL
      ).
      order(<<-SQL
          is_current DESC,
          effective_at DESC,
          CASE
            WHEN change_type_name = 'ADDITION' THEN 3
            WHEN change_type_name = 'RESERVATION' THEN 2
            WHEN change_type_name = 'RESERVATION_WITHDRAWAL' THEN 1
            WHEN change_type_name = 'DELETION' THEN 0
          END,
          subspecies_info DESC
        SQL
      )
  end

  def common_names
    object.common_names.joins(:language).
      select("languages.name_en AS lang").
      select("string_agg(common_names.name, ', ') AS names").
      select(<<-SQL
          CASE
            WHEN UPPER(languages.name_en) = 'ENGLISH' OR
              UPPER(languages.name_en) = 'FRENCH' OR
              UPPER(languages.name_en) = 'SPANISH'
              THEN true
            ELSE false
          END AS convention_language
        SQL
      ).
      group("languages.name_en").order("languages.name_en")
  end

  def distributions
    object.distributions.joins(:geo_entity).
      select('geo_entities.name_en AS name_en').
      joins("LEFT JOIN taggings ON
        taggings.taggable_id = distributions.id
        AND taggings.taggable_type = 'Distribution'
        LEFT JOIN tags ON tags.id = taggings.tag_id").
      select("string_agg(tags.name, ', ') AS tags_list").
      group('geo_entities.name_en').
      order('geo_entities.name_en')
  end

  def subspecies
    TaxonConcept.where(:parent_id => object.id).
      select([:full_name, :author_year]).
      order(:full_name)
  end

  def distribution_references
    object.distributions.joins(:geo_entity).
      joins(:distribution_references => :reference).
      select("geo_entities.name_en AS country").
      select("string_agg(\"references\".citation, '; ') AS country_references").
      group('geo_entities.name_en').
      order('geo_entities.name_en')
  end

  def cached_key
    [object]
  end
end

