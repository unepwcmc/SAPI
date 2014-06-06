class NomenclatureChange::Split < NomenclatureChange
  has_one :input, :class_name => NomenclatureChange::Input,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy
  has_many :outputs, :class_name => NomenclatureChange::Output,
    :foreign_key => :nomenclature_change_id,
    :dependent => :destroy
  accepts_nested_attributes_for :input, :allow_destroy => true
  accepts_nested_attributes_for :outputs, :allow_destroy => true

  def summary
    [
      input.taxon_concept.full_name,
      outputs.map { |output| output_summary(output) }
    ]
  end

  private

  def output_summary(output)
    [
      output.taxon_concept.try(:full_name),
      [
        output_children_summary(output),
        output_names_summary(output),
        output_distribution_summary(output),
        output_generic_summary(output, input.taxon_concept.taxon_commons, 'common names'),
        output_generic_summary(output, input.taxon_concept.listing_changes, 'listing changes'),
        output_generic_summary(output, input.taxon_concept.taxon_instruments, 'CMS instruments'),
        output_generic_summary(output, input.taxon_concept.cites_suspensions, 'CITES suspensions'),
        output_generic_summary(output, input.taxon_concept.quotas, 'CITES quotas'),
        output_generic_summary(output, input.taxon_concept.eu_suspensions, 'EU suspensions'),
        output_generic_summary(output, input.taxon_concept.eu_opinions, 'EU opinions'),
        output_generic_summary(output, input.taxon_concept.taxon_concept_references, 'references')
      ].compact
    ]
  end

  def output_children_summary(output)
    children_cnt = input.taxon_concept.children.count
    return nil unless children_cnt > 0
    cnt = input.parent_reassignments.includes(:reassignment_targets).
      where(
        'nomenclature_change_reassignment_targets.nomenclature_change_output_id' => output.id
      ).count
    "#{cnt} (of #{children_cnt}) children"
  end

  def output_names_summary(output)
    names_cnt =
      input.taxon_concept.synonyms.count +
      input.taxon_concept.hybrids.count +
      input.taxon_concept.trade_names.count
    return nil unless names_cnt > 0
    cnt = input.name_reassignments.includes(:reassignment_targets).
      where(
        'nomenclature_change_reassignment_targets.nomenclature_change_output_id' => output.id
      ).count
    "#{cnt} (of #{names_cnt}) names"
  end

  def output_distribution_summary(output)
    distributions_cnt = input.taxon_concept.distributions.count
    return nil unless distributions_cnt > 0
    cnt = input.distribution_reassignments.includes(:reassignment_targets).
      where(
        'nomenclature_change_reassignment_targets.nomenclature_change_output_id' => output.id
      ).count
    "#{cnt} (of #{distributions_cnt}) distributions"
  end

  def output_generic_summary(output, rel, title)
    objects_cnt = rel.count
    return nil unless objects_cnt > 0
    "#{objects_cnt} (of #{objects_cnt}) #{title}"
  end
end
