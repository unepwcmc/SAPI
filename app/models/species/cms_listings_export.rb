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
      :original_taxon_concept_full_note_en
    ]
  end

  def csv_column_headers
    [
      'Id', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'ScientificName', 
      'Author', 'Rank', 'Agreement', 'Listing', 'Listed under', 'Date', 'Note'
    ]
  end

end
