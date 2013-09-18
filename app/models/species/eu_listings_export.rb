class Species::EuListingsExport < Species::ListingsExport

  def initialize(designation, filters)
    super(designation, filters)
    @include_cites = filters[:include_cites] == "true"
  end

private

  def designation_name
    'eu'
  end

  def sql_columns
    columns = [
      :id, :kingdom_name, :phylum_name, :class_name, :order_name, :family_name,
      :genus_name, :species_name, :subspecies_name,
      :full_name, :author_year, :rank_name, :"#{@designation.name.downcase}_listing_original"
    ]
    if @include_cites
      columns << :cites_listing_original
    end
    columns + [
      :original_taxon_concept_party_iso_code, :original_taxon_concept_full_name_with_spp,
      :original_taxon_concept_full_note_en, :original_taxon_concept_hash_full_note_en
    ]
  end

  def csv_column_headers
    headers = [
      'Id', 'Kingdom', 'Phylum', 'Class', 'Order', 'Family',
      'Genus', 'Species', 'Subspecies',
      'Scientific Name', 'Author', 'Rank', 'Listing'
    ]
    if @include_cites
      headers << 'CITES'
    end
    headers + ['Party', 'Listed under', 'Full note', '# Full note']
  end

end
