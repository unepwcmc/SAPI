module NomenclatureChange::ConstructorHelpers

  def _build_single_target(reassignment, output)
    reassignment.reassignment_targets.build(nomenclature_change_output_id: output.id)
  end

  def _build_multiple_targets(reassignment, outputs)
    outputs.each do |output|
      reassignment.reassignment_targets.build(nomenclature_change_output_id: output.id)
    end
  end

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
      _build_parent_reassignment(child, input, output)
    end
  end

  def _build_parent_reassignment(child, input, output)
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
      _build_name_reassignment(relationship, input, outputs)
    end
  end

  def _build_name_reassignment(relationship, input, outputs)
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
      _build_multiple_targets(reassignment, outputs.select do |o|
        o.taxon_concept_id != reassignment.reassignable.other_taxon_concept_id
      end)
    end
    reassignment
  end

  def _build_distribution_reassignments(input, outputs)
    distributions = input.taxon_concept.
      distributions.includes(:geo_entity).order('geo_entities.name_en')
    input.distribution_reassignments = distributions.map do |distribution|
      _build_distribution_reassignment(distribution, input, outputs)
    end
  end

  def _build_distribution_reassignment(distribution, input, outputs)
    reassignment_attrs = {
      reassignable_type: 'Distribution',
      reassignable_id: distribution.id
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

  def _build_legislation_reassignments(input, outputs)
    event = @nomenclature_change.event
    input.legislation_reassignments = [
      :listing_changes, :cites_suspensions, :quotas, :eu_suspensions, :eu_opinions
    ].map do |legislation_collection_name|
      _build_legislation_type_reassignment(legislation_collection_name, input)
    end.compact
    input.legislation_reassignments.each do |reassignment|
      _build_multiple_targets(reassignment, outputs)
    end
  end

  def _build_legislation_type_reassignment(legislation_collection_name, input)
    legislation_type = legislation_collection_name.to_s.singularize.camelize
    public_note = send(:"multi_lingual_#{legislation_collection_name.to_s.singularize}_note")
    input.send(:"#{legislation_collection_name}_reassignments").first ||
      input.taxon_concept.send(legislation_collection_name).limit(1).count > 0 &&
      NomenclatureChange::LegislationReassignment.new(
        reassignable_type: legislation_type,
        note_en: public_note[:en],
        note_es: public_note[:es],
        note_fr: public_note[:fr]
      ) || nil
  end

  def _build_reassignable_type_reassignment(reassignable_collection_name, input)
    reassignable_type = reassignable_collection_name.to_s.singularize.camelize
    input.send(:"#{reassignable_collection_name}_reassignments").first ||
      input.taxon_concept.send(reassignable_collection_name).limit(1).count > 0 &&
      NomenclatureChange::Reassignment.new(
        reassignable_type: reassignable_type,
        type: 'NomenclatureChange::Reassignment'
      ) || nil
  end

  def _build_common_names_reassignments(input, outputs)
    reassignment = _build_reassignable_type_reassignment(:taxon_commons, input)
    if reassignment
      _build_multiple_targets(reassignment, outputs)
      input.reassignments << reassignment
    end
  end

  def _build_references_reassignments(input, outputs)
    reassignment = _build_reassignable_type_reassignment(:taxon_concept_references, input)
    if reassignment
      _build_multiple_targets(reassignment, outputs)
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
      _build_single_target(reassignment, output)
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
