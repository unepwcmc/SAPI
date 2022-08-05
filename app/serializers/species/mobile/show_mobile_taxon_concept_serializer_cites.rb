class Species::Mobile::ShowMobileTaxonConceptSerializerCites < Species::Mobile::ShowMobileTaxonConceptSerializer

attributes :id, :parent_id, :full_name, :author_year, 
    :common_names, :distributions, :subspecies, 
    :taxonomy, :kingdom_name, :phylum_name, :order_name, :class_name, :family_name,
    :genus_name, :species_name, :rank_name, :name_status, :nomenclature_note_en, :nomenclature_notification



  def distributions_with_tags_and_references
    Distribution.from('api_distributions_view distributions').
      where(taxon_concept_id: object.id).
      select("name_en AS name, name_en AS country, ARRAY_TO_STRING(tags,  ',') AS tags_list").
      order('name_en').all
  end

  def distributions
    distributions_with_tags_and_references
  end

end
