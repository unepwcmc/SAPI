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
    remark = ""
    case restriction.taxon_concept.try(:name_status)
      when "A"
        taxon = restriction.taxon_concept.try(:m_taxon_concept)
      when "H"
        taxon = restriction.taxon_concept.hybrid_parents.
          first.try(:m_taxon_concept) ||
          taxon_issued.m_taxon_concept
          remark = "Issued for hybrid #{restriction.taxon_concept.full_name}"
      when "S"
        taxon = restriction.taxon_concept.accepted_names.
          first.try(:m_taxon_concept) ||
          taxon_issued.m_taxon_concept
        remark = "Issued for synonym #{restriction.taxon_concept.full_name}"
      else
        taxon = nil
    end
    return [""]*(TAXONOMY_COLUMNS.size+1) unless taxon #return array with empty strings
    TAXONOMY_COLUMNS.each do |c|
      columns << taxon.send(c)
    end
    columns << remark
    columns
  end
end
