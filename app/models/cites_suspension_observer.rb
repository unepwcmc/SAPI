class CitesSuspensionObserver < ActiveRecord::Observer

  def after_save(cites_suspension)
    if cites_suspension.taxon_concept
      cites_suspension.taxon_concept.touch
    elsif cites_suspension.taxon_concept_id_was != cites_suspension.taxon_concept_id
      TaxonConcept.find(cites_suspension.taxon_concept_id_was).touch
    else
      touch_taxa_with_applicable_distribution(cites_suspension)
    end
  end

  def after_destroy(cites_suspension)
    if cites_suspension.taxon_concept
      cites_suspension.taxon_concept.touch
    else
      touch_taxa_with_applicable_distribution(cites_suspension)
    end
    DownloadsCache.clear_cites_suspensions
  end

  def touch_taxa_with_applicable_distribution(cites_suspension)
    update_stmt = TaxonConcept.send(:sanitize_sql_array, [
      "UPDATE taxon_concepts
      SET updated_at = NOW()
      FROM distributions
      WHERE distributions.taxon_concept_id = taxon_concepts.id
      AND distributions.geo_entity_id IN (:geo_entity_id)",
      :geo_entity_id => [
        cites_suspension.geo_entity_id, cites_suspension.geo_entity_id_was
      ].compact.uniq
    ])
    TaxonConcept.connection.execute update_stmt
  end

end
