class TradeRestrictionObserver < ActiveRecord::Observer

  def after_save(trade_restriction)
    if trade_restriction.taxon_concept.nil?
      touch_taxa_with_applicable_distribution(trade_restriction)
    end
  end

  def after_destroy(trade_restriction)
    if trade_restriction.taxon_concept.nil?
      touch_taxa_with_applicable_distribution(trade_restriction)
    end
  end

  private

  def touch_taxa_with_applicable_distribution(trade_restriction)
    update_stmt = TaxonConcept.send(:sanitize_sql_array, [
      "UPDATE taxon_concepts
      SET dependents_updated_at = NOW(), dependents_updated_by_id = :updated_by_id
      FROM distributions
      WHERE distributions.taxon_concept_id = taxon_concepts.id
      AND distributions.geo_entity_id IN (:geo_entity_id)",
      :updated_by_id => trade_restriction.updated_by_id,
      :geo_entity_id => [
        trade_restriction.geo_entity_id, trade_restriction.geo_entity_id_was
      ].compact.uniq
    ])
    TaxonConcept.connection.execute update_stmt
  end

end
