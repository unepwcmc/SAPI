class Species::TaxonConceptsFullListExport < Species::CsvCopyExport

  def query
    rel = MTaxonConcept.from(table_name).order('taxonomic_position')
    rel = rel.where(:show_in_species_plus => true)
             .by_cites_eu_taxonomy
             # .includes(:cites_listing_changes)
             # .merge(MCitesListingChange.where(is_current: true))
    rel.select(sql_columns)
  end

  private

  def resource_name
    'species_list'
  end

  def table_name
    'taxon_concepts_mview'
  end

  def sql_columns
    [
       "id", "parent_id", "full_name", "name_status", "rank_name",
       "rank_display_name_es", "rank_display_name_fr",
       "cites_accepted", "kingdom_name", "phylum_name",
       "class_name", "order_name", "family_name", "subfamily_name", "genus_name",
       "species_name", "subspecies_name", "cites_status", "cites_listing",
       "eu_status", "eu_listing", "author_year", "created_at", "updated_at",
       "english_names_ary", "spanish_names_ary", "french_names_ary", "synonyms_ary",
       "synonyms_author_years_ary", "all_distribution_iso_codes_ary", "all_distribution_ary_en"
    ]
    # 'cites_listing_changes_mview.change_type_name', 'cites_listing_changes_mview.full_note_en',
    # 'cites_listing_changes_mview.full_note_es', 'cites_listing_changes_mview.full_note_fr',
  end

  def csv_column_headers
    [
      'Species ID', 'Species Parent ID', 'Scientific Name', 'Name Status',
      'Rank EN', 'Rank ES', 'Rank FR', 'Cites Accepted', 'Kingdom', 'Phylum',
      'Class', 'Order', 'Family', 'Subfamily', 'Genus', 'Species', 'Subspecies',
      'CITES Status', 'CITES Listing', 'EU Status', 'EU Listing', 'Author',
      'Date added', 'Date updated', 'English Names', 'Spanish Names', 'French Names',
      'Synonyms', 'Synonyms Author', 'Distribution ISO Code 2', 'Distribution'
    ]
    #, 'Listing Change Type',
    # 'Listing Changes Note EN', 'Listing Changes Note ES', 'Listing Changes Note FR'
  end
end
