class Species::CitesListingsExport < Species::ListingsExport
private

  def designation_name
    'cites'
  end

  def sql_columns
    [
      :id, :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
      :genus_name, :species_name, :subspecies_name,
      :full_name, :author_year, :rank_name, :"#{designation_name}_listing_original",
      :original_taxon_concept_party_iso_code, :original_taxon_concept_full_name_with_spp,
      :original_taxon_concept_full_note_en, :original_taxon_concept_hash_full_note_en,
      :all_distribution, :all_distribution_iso_codes,
      :native_distribution, :introduced_distribution,
      :introduced_uncertain_distribution, :reintroduced_distribution,
      :extinct_distribution, :extinct_uncertain_distribution,
      :uncertain_distribution
    ]
  end

  def csv_column_headers
    [
      'Id', 'Kingdom', 'Phylum', 'Class', 'Order', 'Family',
      'Genus', 'Species', 'Subspecies',
      'Scientific Name', 'Author', 'Rank', 'Listing',
      'Party', 'Listed under', 'Full note', '# Full note',
      'All_DistributionFullNames', 'All_DistributionISOCodes',
      'NativeDistributionFullNames', 'Introduced_Distribution',
      'Introduced(?)_Distribution', 'Reintroduced_Distribution',
      'Extinct_Distribution', 'Extinct(?)_Distribution',
      'Distribution_Uncertain'
    ]
  end
end
