class Species::RestrictionsExport
  TAXONOMY_COLUMNS = [
    :kingdom_name, :phylum_name,
    :class_name, :order_name,
    :family_name, :genus_name,
    :species_name, :subspecies_name,
    :full_name, :rank_name
  ]

  def self.fill_taxon_columns restriction
    columns = []
    taxon_issued = restriction.taxon_concept
    if taxon_issued.name_status == "A"
      taxon = taxon_issued.m_taxon_concept
      remark = ""
    else
      taxon = taxon_issued.accepted_names.first.m_taxon_concept
      remark = "Issued for #{taxon_issued.name_status == 'S' ? 'synonym' : 'hybrid' }
        #{taxon_issued.full_name}"
    end
    return [""]*(TAXONOMY_COLUMNS.size+1) unless taxon #return array with empty strings
    TAXONOMY_COLUMNS.each do |c|
      columns << taxon.send(c)
    end
    columns << remark
    columns
  end
end
