class Species::CmsListingsExport < Species::ListingsExport

  private

  def designation_name
    'cms'
  end

  def sql_columns
    [
      :id, :phylum_name, :class_name, :order_name, :family_name, :genus_name,
      :full_name, :author_year, :rank_name, :agreement, :cms_listing_original,
      :original_taxon_concept_full_name_with_spp, :original_taxon_concept_effective_at,
      :original_taxon_concept_full_note_en,
      :all_distribution, :all_distribution_iso_codes,
      :native_distribution, :introduced_distribution,
      :introduced_uncertain_distribution, :reintroduced_distribution,
      :extinct_distribution, :extinct_uncertain_distribution,
      :uncertain_distribution
    ]
  end

  def csv_column_headers
    [
      'Id', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'ScientificName',
      'Author', 'Rank', 'Agreement', 'Listing', 'Listed under', 'Date', 'Note',
      'All_DistributionFullNames', 'All_DistributionISOCodes',
      'NativeDistributionFullNames', 'Introduced_Distribution',
      'Introduced(?)_Distribution', 'Reintroduced_Distribution',
      'Extinct_Distribution', 'Extinct(?)_Distribution',
      'Distribution_Uncertain'
    ]
  end

end
