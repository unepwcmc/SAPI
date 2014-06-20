module NomenclatureChange::ConstructorHelpers

  def _build_parent_reassignments(input, output, children)
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
  def _build_names_reassignments(input, outputs = nil)
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
  def _build_distribution_reassignments(input, outputs = nil)
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
  def _build_legislation_reassignments(input, outputs = nil)
    event = @nomenclature_change.event
    input.legislation_reassignments = [
      input.legislation_reassignments.where(
        :reassignable_type => 'ListingChange'
      ).first || input.taxon_concept.listing_changes.limit(1).count > 0 &&
      NomenclatureChange::LegislationReassignment.new(
        :reassignable_type => 'ListingChange',
        :note => "Originally listed as #{input.taxon_concept.full_name}, from which [[output]] was split following #{event.try(:name)}"
      ) || nil,
      input.legislation_reassignments.where(
        :reassignable_type => 'CitesSuspension'
      ).first || input.taxon_concept.cites_suspensions.limit(1).count > 0 &&
      NomenclatureChange::LegislationReassignment.new(
        :reassignable_type => 'CitesSuspension',
        :note => "Suspension originally formed for #{input.taxon_concept.full_name}, from which [[output]] was split following #{event.try(:name)}"
      ) || nil,
      input.legislation_reassignments.where(
        :reassignable_type => 'Quota'
      ).first || input.taxon_concept.quotas.limit(1).count > 0 &&
      NomenclatureChange::LegislationReassignment.new(
        :reassignable_type => 'Quota',
        :note => "Quota originally published for #{input.taxon_concept.full_name}, from which [[output]] was split following #{event.try(:name)}"
      ) || nil,
      input.legislation_reassignments.where(
        :reassignable_type => 'EuSuspension'
      ).first || input.taxon_concept.eu_suspensions.limit(1).count > 0 &&
      NomenclatureChange::LegislationReassignment.new(
        :reassignable_type => 'EuSuspension',
        :note => "Suspension originally formed for #{input.taxon_concept.full_name}, from which [[output]] was split following #{event.try(:name)}"
      ) || nil,
      input.legislation_reassignments.where(
        :reassignable_type => 'EuOpinion'
      ).first || input.taxon_concept.eu_opinions.limit(1).count > 0 &&
      NomenclatureChange::LegislationReassignment.new(
        :reassignable_type => 'EuOpinion',
        :note => "Opinion originally formed for #{input.taxon_concept.full_name}, from which [[output]] was split following #{event.try(:name)}"
      ) || nil
    ].compact
    unless outputs.nil?
      input.legislation_reassignments.each do |reassignment|
        outputs.map do |output|
          reassignment.reassignment_targets.build(:nomenclature_change_output_id => output.id)
        end
      end
    end
  end

  # if outputs not passed, goes to all outputs
  # in which case no need to create reassignment targets
  def _build_common_names_reassignments(input, outputs = nil)
    unless input.reassignments.where(
      :reassignable_type => 'TaxonCommon'
    ).first || input.taxon_concept.taxon_commons.limit(1).count == 0
      reassignment = NomenclatureChange::Reassignment.new(
        :reassignable_type => 'TaxonCommon',
        :type => 'NomenclatureChange::Reassignment'
      )
      unless outputs.nil?
        outputs.map do |output|
          reassignment.reassignment_targets.build(:nomenclature_change_output_id => output.id)
        end
      end
      input.reassignments << reassignment
    end
  end

  # if outputs not passed, goes to all outputs
  # in which case no need to create reassignment targets
  def _build_references_reassignments(input, outputs = nil)
    unless input.reassignments.where(
      :reassignable_type => 'TaxonConceptReference'
    ).first || input.taxon_concept.taxon_concept_references.limit(1).count == 0
      reassignment = NomenclatureChange::Reassignment.new(
        :reassignable_type => 'TaxonConceptReference',
        :type => 'NomenclatureChange::Reassignment'
      )
      unless outputs.nil?
        outputs.map do |output|
          reassignment.reassignment_targets.build(:nomenclature_change_output_id => output.id)
        end
      end
      input.reassignments << reassignment
    end
  end

end
