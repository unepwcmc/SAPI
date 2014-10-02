module NomenclatureChange::ConstructorHelpers

  def taxon_concept_html(full_name, rank_name)
    if [Rank::GENUS, Rank::SPECIES, Rank::SUBSPECIES, Rank::VARIETY].
      include?(rank_name)
      "<i>#{full_name}</i>"
    elsif [Rank::CLASS, Rank::ORDER, Rank::FAMILY, Rank::SUBFAMILY].
      include?(rank_name)
      full_name.upcase
    end
  end

  def _build_parent_reassignments(input, output, children = nil)
    children ||= input.taxon_concept.children
    input.parent_reassignments = children.map do |child|
      reassignment_attrs = {
        reassignable_type: 'TaxonConcept',
        reassignable_id: child.id
      }
      reassignment = input.parent_reassignments.where(
        reassignment_attrs
      ).first
      unless reassignment
        reassignment = NomenclatureChange::ParentReassignment.new(
          reassignment_attrs
        )
        reassignment.build_reassignment_target(nomenclature_change_output_id: output.id)
      end
      reassignment
    end
  end

  def _build_names_reassignments(input, outputs, all_outputs = nil)
    relationships = input.taxon_concept.taxon_relationships.
      includes(:other_taxon_concept).
      order(:taxon_relationship_type_id, 'taxon_concepts.full_name')
    if all_outputs
      # do not reassign relationships that involve outputs
      # e.g. in case a synonym of the input of a split is one of the outputs
      taxon_concepts_ids = all_outputs.map(&:taxon_concept_id)
      relationships = relationships.reject do |relationship|
        taxon_concepts_ids.include?(relationship.other_taxon_concept_id)
      end
    end
    input.name_reassignments = relationships.map do |relationship|
      reassignment_attrs = {
        reassignable_type: 'TaxonRelationship',
        reassignable_id: relationship.id
      }
      reassignment = input.name_reassignments.where(
        reassignment_attrs
      ).first
      if reassignment.nil?
        reassignment = NomenclatureChange::NameReassignment.new(
          reassignment_attrs
        )
        outputs.each do |output|
          unless reassignment.reassignable_type == 'TaxonRelationship' &&
            output.taxon_concept_id == reassignment.reassignable.other_taxon_concept_id
            reassignment.reassignment_targets.build(
              nomenclature_change_output_id: output.id
            )
          end
        end
      end
      reassignment
    end
  end

  def _build_distribution_reassignments(input, outputs)
    distributions = input.taxon_concept.
      distributions.includes(:geo_entity).order('geo_entities.name_en')
    input.distribution_reassignments = distributions.map do |distr|
      reassignment_attrs = {
        reassignable_type: 'Distribution',
        reassignable_id: distr.id
      }
      reassignment = input.distribution_reassignments.where(
        reassignment_attrs
      ).first
      if reassignment.nil?
        reassignment = NomenclatureChange::DistributionReassignment.new(
          reassignment_attrs
        )
        outputs.map do |output|
          reassignment.reassignment_targets.build(nomenclature_change_output_id: output.id)
        end
      end
      reassignment
    end
  end

  def _build_legislation_reassignments(input, outputs)
    event = @nomenclature_change.event
    input.legislation_reassignments = [
      input.legislation_reassignments.where(
        reassignable_type: 'ListingChange'
      ).first || input.taxon_concept.listing_changes.limit(1).count > 0 &&
      # multi_lingual_listing_change_note defined in constructor
      (note = multi_lingual_listing_change_note) &&
      NomenclatureChange::LegislationReassignment.new(
        reassignable_type: 'ListingChange',
        note_en: note[:en],
        note_es: note[:es],
        note_fr: note[:fr]
      ) || nil,
      input.legislation_reassignments.where(
        reassignable_type: 'CitesSuspension'
      ).first || input.taxon_concept.cites_suspensions.limit(1).count > 0 &&
      # multi_lingual_suspension_note defined in constructor
      (note = multi_lingual_suspension_note) &&
      NomenclatureChange::LegislationReassignment.new(
        reassignable_type: 'CitesSuspension',
        note_en: note[:en],
        note_es: note[:es],
        note_fr: note[:fr]
      ) || nil,
      input.legislation_reassignments.where(
        reassignable_type: 'Quota'
      ).first || input.taxon_concept.quotas.limit(1).count > 0 &&
      # multi_lingual_quota_note defined in constructor
      (note = multi_lingual_quota_note) &&
      NomenclatureChange::LegislationReassignment.new(
        reassignable_type: 'Quota',
        note_en: note[:en],
        note_es: note[:es],
        note_fr: note[:fr]
      ) || nil,
      input.legislation_reassignments.where(
        reassignable_type: 'EuSuspension'
      ).first || input.taxon_concept.eu_suspensions.limit(1).count > 0 &&
      # multi_lingual_suspension_note defined in constructor
      (note = multi_lingual_suspension_note) &&
      NomenclatureChange::LegislationReassignment.new(
        reassignable_type: 'EuSuspension',
        note_en: note[:en],
        note_es: note[:es],
        note_fr: note[:fr]
      ) || nil,
      input.legislation_reassignments.where(
        reassignable_type: 'EuOpinion'
      ).first || input.taxon_concept.eu_opinions.limit(1).count > 0 &&
      # multi_lingual_opinion_note defined in constructor
      (note = multi_lingual_opinion_note) &&
      NomenclatureChange::LegislationReassignment.new(
        reassignable_type: 'EuOpinion',
        note_en: note[:en],
        note_es: note[:es],
        note_fr: note[:fr]
      ) || nil
    ].compact
    input.legislation_reassignments.each do |reassignment|
      outputs.each do |output|
        reassignment.reassignment_targets.build(nomenclature_change_output_id: output.id)
      end
    end
  end

  def _build_common_names_reassignments(input, outputs)
    unless input.reassignments.where(
      reassignable_type: 'TaxonCommon'
    ).first || input.taxon_concept.taxon_commons.limit(1).count == 0
      reassignment = NomenclatureChange::Reassignment.new(
        reassignable_type: 'TaxonCommon',
        type: 'NomenclatureChange::Reassignment'
      )
      outputs.each do |output|
        reassignment.reassignment_targets.build(nomenclature_change_output_id: output.id)
      end
      input.reassignments << reassignment
    end
  end

  def _build_references_reassignments(input, outputs)
    unless input.reassignments.where(
      reassignable_type: 'TaxonConceptReference'
    ).first || input.taxon_concept.taxon_concept_references.limit(1).count == 0
      reassignment = NomenclatureChange::Reassignment.new(
        reassignable_type: 'TaxonConceptReference',
        type: 'NomenclatureChange::Reassignment'
      )
      outputs.each do |output|
        reassignment.reassignment_targets.build(nomenclature_change_output_id: output.id)
      end
      input.reassignments << reassignment
    end
  end

  def _build_trade_reassignments(input, output)
    unless input.reassignments.where(
      reassignable_type: 'Trade::Shipment'
    ).first || input.taxon_concept.shipments.limit(1).count == 0
      reassignment = NomenclatureChange::Reassignment.new(
        reassignable_type: 'Trade::Shipment',
        type: 'NomenclatureChange::Reassignment'
      )
      reassignment.reassignment_targets.build(nomenclature_change_output_id: output.id)
      input.reassignments << reassignment
    end
  end

  def following_taxonomic_changes(event, lng)
    I18n.with_locale(lng) do
      I18n.translate(
        'following_taxonomic_changes',
        event: event.name,
        default: ''
      )
    end
  end

  def multi_lingual_legislation_note(note_type)
    result = {}
    [:en, :es, :fr].each do |lng|
      result[lng] = legislation_note(lng) do |input_html, output_html|
        I18n.with_locale(lng) do
          I18n.translate(
            note_type,
            input_taxon: input_html, output_taxon: output_html,
            default: 'Translation missing'
          )
        end
      end
    end
    result
  end

end
