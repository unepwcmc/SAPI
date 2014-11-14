class Species::RestrictionsExport
  TAXONOMY_COLUMNS = [
    :kingdom_name, :phylum_name,
    :class_name, :order_name,
    :family_name, :genus_name,
    :species_name, :subspecies_name,
    :full_name, :rank_name
  ]

  TAXONOMY_COLUMN_NAMES = [
    'Kingdom', 'Phylum',
    'Class', 'Order',
    'Family', 'Genus',
    'Species', 'Subspecies',
    'Full Name', 'Rank'
  ]

  def self.fill_taxon_columns restriction
    columns = []
    case restriction.taxon_concept.try(:name_status)
      when "A"
        taxon = restriction.taxon_concept.try(:m_taxon_concept)
      when "H"
        taxon = restriction.taxon_concept.hybrid_parents.
          first.try(:m_taxon_concept) ||
          restriction.taxon_concept.m_taxon_concept
      when "S"
        taxon = restriction.taxon_concept.accepted_names.
          first.try(:m_taxon_concept) ||
          restriction.taxon_concept.m_taxon_concept
      else
        taxon = nil
    end
    return [""]*(TAXONOMY_COLUMNS.size+1) unless taxon #return array with empty strings
    TAXONOMY_COLUMNS.each do |c|
      columns << taxon.send(c)
    end
    columns
  end
end
