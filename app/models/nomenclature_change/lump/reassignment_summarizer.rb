class NomenclatureChange::Lump::ReassignmentSummarizer

  def initialize(input, output)
    @input = input
    @output = output
  end

  def summary
    [
      output_children_summary,
      output_names_summary,
      output_distribution_summary,
      output_generic_summary(
        @input.taxon_concept.taxon_commons,
        'TaxonCommon', 'common names'
      ),
      output_legislation_summary(
        @input.taxon_concept.listing_changes,
        'ListingChange', 'listing changes'
      ),
      output_legislation_summary(
        @input.taxon_concept.taxon_instruments,
        'TaxonInstrument', 'CMS instruments'
      ),
      output_legislation_summary(
        @input.taxon_concept.cites_suspensions,
        'CitesSuspension', 'CITES suspensions'
      ),
      output_legislation_summary(
        @input.taxon_concept.quotas,
        'Quota', 'CITES quotas'
      ),
      output_legislation_summary(
        @input.taxon_concept.eu_suspensions,
        'EuSuspension', 'EU suspensions'
      ),
      output_generic_summary(
        @input.taxon_concept.eu_opinions,
        'EuOpinion', 'EU opinions'
      ),
      output_generic_summary(
        @input.taxon_concept.taxon_concept_references,
        'TaxonReference', 'references'
      )
    ].compact
  end

  private

  def output_children_summary
    children_cnt = @input.taxon_concept.children.count
    return nil unless children_cnt > 0
    cnt = @input.parent_reassignments.includes(:reassignment_targets).
      where(
        'nomenclature_change_reassignment_targets.nomenclature_change_output_id' => @output.id
      ).count
    "#{cnt} (of #{children_cnt}) children"
  end

  def output_names_summary
    names_cnt =
      @input.taxon_concept.synonyms.count +
      @input.taxon_concept.hybrids.count +
      @input.taxon_concept.trade_names.count
    return nil unless names_cnt > 0
    cnt = @input.name_reassignments.includes(:reassignment_targets).
      where(
        'nomenclature_change_reassignment_targets.nomenclature_change_output_id' => @output.id
      ).count
    "#{cnt} (of #{names_cnt}) names"
  end

  def output_distribution_summary
    distributions_cnt = @input.taxon_concept.distributions.count
    return nil unless distributions_cnt > 0
    cnt = @input.distribution_reassignments.includes(:reassignment_targets).
      where(
        'nomenclature_change_reassignment_targets.nomenclature_change_output_id' => @output.id
      ).count
    "#{cnt} (of #{distributions_cnt}) distributions"
  end

  def output_legislation_summary(rel, reassignable_type, title)
    objects_cnt = rel.count
    return nil unless objects_cnt > 0
    cnt = @input.legislation_reassignments.includes(:reassignment_targets).
      where(
        'nomenclature_change_reassignment_targets.nomenclature_change_output_id' => @output.id
      ).where(:reassignable_type => reassignable_type).count
    puts "#{reassignable_type} #{cnt}"
    "#{(cnt == 1 ? objects_cnt : 0)} (of #{objects_cnt}) #{title}"
  end

  def output_generic_summary(rel, reassignable_type, title)
    objects_cnt = rel.count
    return nil unless objects_cnt > 0
    cnt = @input.reassignments.includes(:reassignment_targets).
      where(
        'nomenclature_change_reassignment_targets.nomenclature_change_output_id' => @output.id
      ).where(:reassignable_type => reassignable_type).count
    puts "#{reassignable_type} #{cnt}"
    "#{(cnt == 1 ? objects_cnt : 0)} (of #{objects_cnt}) #{title}"
  end

end
