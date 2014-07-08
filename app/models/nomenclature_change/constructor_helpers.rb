module NomenclatureChange::ConstructorHelpers

  def taxon_concept_html(full_name, rank_name)
    if [Rank::GENUS, Rank::SPECIES, Rank::SUBSPECIES, Rank::VARIETY].
      include?(rank_name)
      "<i>#{full_name}</i>"
    elsif [Rank.CLASS, Rank::OORDEr, Rank::FAMILY, Rank::SUBFAMILY].
      include?(rank_name)
      full_name.upcase
    end
  end

  def _build_parent_reassignments(input, output, children = nil)
    children ||= input.taxon_concept.children
    input.parent_reassignments = children.map do |child|
      reassignment_attrs = {
        :reassignable_type => 'TaxonConcept',
        :reassignable_id => child.id
      }
      reassignment = input.parent_reassignments.where(
        reassignment_attrs
      ).first
      unless reassignment
        reassignment = NomenclatureChange::ParentReassignment.new(
          reassignment_attrs
        )
        reassignment.build_reassignment_target(:nomenclature_change_output_id => output.id)
      end
      reassignment
    end
  end

  # if outputs not passed, goes to all outputs
  # in which case no need to create reassignment targets
  def _build_names_reassignments(input, outputs)
    relationships = input.taxon_concept.taxon_relationships.
      includes(:other_taxon_concept).
      order(:taxon_relationship_type_id, 'taxon_concepts.full_name')
    input.name_reassignments = relationships.map do |relationship|
      reassignment_attrs = {
        :reassignable_type => 'TaxonRelationship',
        :reassignable_id => relationship.id
      }
      reassignments = input.name_reassignments.where(
        reassignment_attrs
      )
      if reassignments.empty?
        r = NomenclatureChange::NameReassignment.new(
          reassignment_attrs
        )
        outputs.map do |output|
          r.reassignment_targets.build(:nomenclature_change_output_id => output.id)
        end
        reassignments = [r]
      end
      reassignments
    end.flatten
  end

  # if outputs not passed, goes to all outputs
  # in which case no need to create reassignment targets
  def _build_distribution_reassignments(input, outputs)
    distributions = input.taxon_concept.
      distributions.includes(:geo_entity).order('geo_entities.name_en')
    input.distribution_reassignments = distributions.map do |distr|
      reassignment_attrs = {
        :reassignable_type => 'Distribution',
        :reassignable_id => distr.id
      }
      reassignments = input.distribution_reassignments.where(
        reassignment_attrs
      )
      if reassignments.empty?
        r = NomenclatureChange::DistributionReassignment.new(
          reassignment_attrs
        )
        outputs.map do |output|
          r.reassignment_targets.build(:nomenclature_change_output_id => output.id)
        end
        reassignments = [r]
      end
      reassignments
    end.flatten
  end

  # if outputs not passed, goes to all outputs
  # in which case no need to create reassignment targets
  def _build_legislation_reassignments(input, outputs)
    event = @nomenclature_change.event
    input.legislation_reassignments = [
      input.legislation_reassignments.where(
        :reassignable_type => 'ListingChange'
      ).first || input.taxon_concept.listing_changes.limit(1).count > 0 &&
      NomenclatureChange::LegislationReassignment.new(
        :reassignable_type => 'ListingChange',
        # listing_change_note defined in constructor
        :note => listing_change_note
      ) || nil,
      input.legislation_reassignments.where(
        :reassignable_type => 'CitesSuspension'
      ).first || input.taxon_concept.cites_suspensions.limit(1).count > 0 &&
      NomenclatureChange::LegislationReassignment.new(
        :reassignable_type => 'CitesSuspension',
        # suspension_note defined in constructor
        :note => suspension_note
      ) || nil,
      input.legislation_reassignments.where(
        :reassignable_type => 'Quota'
      ).first || input.taxon_concept.quotas.limit(1).count > 0 &&
      NomenclatureChange::LegislationReassignment.new(
        :reassignable_type => 'Quota',
        # quota defined in constructor
        :note => quota_note
      ) || nil,
      input.legislation_reassignments.where(
        :reassignable_type => 'EuSuspension'
      ).first || input.taxon_concept.eu_suspensions.limit(1).count > 0 &&
      NomenclatureChange::LegislationReassignment.new(
        :reassignable_type => 'EuSuspension',
        # suspension_note defined in constructor
        :note => suspension_note
      ) || nil,
      input.legislation_reassignments.where(
        :reassignable_type => 'EuOpinion'
      ).first || input.taxon_concept.eu_opinions.limit(1).count > 0 &&
      NomenclatureChange::LegislationReassignment.new(
        :reassignable_type => 'EuOpinion',
        # opinion_note defined in constructor
        :note => opinion_note
      ) || nil
    ].compact
    input.legislation_reassignments.each do |reassignment|
      outputs.map do |output|
        reassignment.reassignment_targets.build(:nomenclature_change_output_id => output.id)
      end
    end
  end

  # if outputs not passed, goes to all outputs
  # in which case no need to create reassignment targets
  def _build_common_names_reassignments(input, outputs)
    unless input.reassignments.where(
      :reassignable_type => 'TaxonCommon'
    ).first || input.taxon_concept.taxon_commons.limit(1).count == 0
      reassignment = NomenclatureChange::Reassignment.new(
        :reassignable_type => 'TaxonCommon',
        :type => 'NomenclatureChange::Reassignment'
      )
      outputs.map do |output|
        reassignment.reassignment_targets.build(:nomenclature_change_output_id => output.id)
      end
      input.reassignments << reassignment
    end
  end

  # if outputs not passed, goes to all outputs
  # in which case no need to create reassignment targets
  def _build_references_reassignments(input, outputs)
    unless input.reassignments.where(
      :reassignable_type => 'TaxonConceptReference'
    ).first || input.taxon_concept.taxon_concept_references.limit(1).count == 0
      reassignment = NomenclatureChange::Reassignment.new(
        :reassignable_type => 'TaxonConceptReference',
        :type => 'NomenclatureChange::Reassignment'
      )
      outputs.map do |output|
        reassignment.reassignment_targets.build(:nomenclature_change_output_id => output.id)
      end
      input.reassignments << reassignment
    end
  end

  def _build_trade_reassignments(input, output)
    unless input.reassignments.where(
      :reassignable_type => 'Trade::Shipment'
    ).first || input.taxon_concept.shipments.limit(1).count == 0
      reassignment = NomenclatureChange::Reassignment.new(
        :reassignable_type => 'Trade::Shipment',
        :type => 'NomenclatureChange::Reassignment'
      )
      reassignment.reassignment_targets.build(:nomenclature_change_output_id => output.id)
      input.reassignments << reassignment
    end
  end

end
