class Species::ShowTaxonConceptSerializerCms < Species::ShowTaxonConceptSerializer

  attributes :cms_listing
  has_many :cms_listing_changes, :serializer => Species::ListingChangeSerializer,
    :key => :cms_listings
  has_many :cms_instruments, :serializer => Species::CmsInstrumentsSerializer

  def cms_listing_changes
    MCmsListingChange.from('cms_listing_changes_mview listing_changes_mview').
      where(
        'listing_changes_mview.taxon_concept_id' => object_and_children,
        'listing_changes_mview.show_in_history' => true
      ).
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
      ).
      joins(<<-SQL
              INNER JOIN taxon_concepts_mview
                ON taxon_concepts_mview.id = listing_changes_mview.taxon_concept_id
            SQL
      ).
      select(<<-SQL
              CASE
                WHEN listing_changes_mview.change_type_name = 'DELETION'
                  THEN 'f'
                ELSE listing_changes_mview.is_current
              END AS is_current,
              listing_changes_mview.species_listing_name,
              listing_changes_mview.party_id,
              listing_changes_mview.party_full_name_en,
              listing_changes_mview.effective_at,
              listing_changes_mview.full_note_en,
              listing_changes_mview.short_note_en,
              listing_changes_mview.auto_note_en,
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
          subspecies_info DESC
        SQL
      ).all
  end

  def cms_instruments
    object.taxon_instruments.includes(:instrument)
  end

  def cms_listing
    object.listing && object.listing['cms_listing']
  end

end
