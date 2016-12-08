module NomenclatureChange::ConstructorHelpers
  LOWER_RANKS = [Rank::GENUS, Rank::SPECIES, Rank::SUBSPECIES, Rank::VARIETY]
  HIGHER_RANKS = [Rank::CLASS, Rank::ORDER, Rank::FAMILY, Rank::SUBFAMILY]

  def _build_single_target(reassignment, output)
    reassignment.reassignment_targets.build(nomenclature_change_output_id: output.id)
  end

  def _build_multiple_targets(reassignment, outputs)
    outputs.each do |output|
      reassignment.reassignment_targets.build(nomenclature_change_output_id: output.id)
    end
  end

  def taxon_concept_html(full_name, rank_name, existing_name = "", existing_rank_name = "")
    if LOWER_RANKS.include?(rank_name)
      lower_ranks_cases(full_name, existing_name, existing_rank_name)
    elsif HIGHER_RANKS.include?(rank_name)
      higher_ranks_cases(full_name, existing_name, existing_rank_name)
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
      reassignment = input.parent_reassignment_class.new(
        reassignment_attrs
      )
      if reassignment.respond_to?(:build_reassignment_target)
        reassignment.build_reassignment_target(nomenclature_change_output_id: output.id)
      end
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
      reassignment = input.name_reassignment_class.new(
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
      reassignment = input.distribution_reassignment_class.new(
        reassignment_attrs
      )
      if input.is_a?(NomenclatureChange::Input)
        outputs.map do |output|
          reassignment.reassignment_targets.build(nomenclature_change_output_id: output.id)
        end
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
      if input.is_a?(NomenclatureChange::Input)
        _build_multiple_targets(reassignment, outputs)
      end
      input.reassignments << reassignment
    end
  end

  def _build_legislation_type_reassignment(legislation_collection_name, input)
    legislation_type = legislation_collection_name.to_s.singularize.camelize
    public_note = send(:"multi_lingual_#{legislation_collection_name.to_s.singularize}_note")
    input.taxon_concept.send(legislation_collection_name).limit(1).count > 0 &&
      input.legislation_reassignment_class.new(
        reassignable_type: legislation_type,
        note_en: public_note[:en],
        note_es: public_note[:es],
        note_fr: public_note[:fr]
      ) || nil
  end

  def _build_document_reassignments(input, outputs)
    taxon_concept_citations = input.taxon_concept.
      document_citation_taxon_concepts
    input.document_citation_reassignments =
      taxon_concept_citations.map do |dctc|
        _build_document_reassignment(dctc.document_citation, input, outputs)
      end
  end

  def _build_document_reassignment(document_citation, input, outputs)
    reassignment = input.document_citation_reassignment_class.new(
      reassignable_type: 'DocumentCitation',
      reassignable_id: document_citation.id
    )
    if input.is_a?(NomenclatureChange::Input)
      dc_geo_entities = document_citation.document_citation_geo_entities
      dc_ge_ids = dc_geo_entities.map(&:geo_entity_id)
      tc_distributions = input.taxon_concept.distributions
      input_tc_ge_ids = tc_distributions.map(&:geo_entity_id)
      distribution_reassignments = input.distribution_reassignments
      outputs.each do |output|
        reassigned_distributions = distribution_reassignments.select do |dr|
          dr.reassignment_targets.
          where(nomenclature_change_output_id: output.id).
          any?
        end.map(&:reassignable)
        output_tc_ge_ids = reassigned_distributions.map(&:geo_entity_id)
        dc_ge_ids_to_reassign = (dc_ge_ids & output_tc_ge_ids) + (dc_ge_ids - input_tc_ge_ids)
        # reassign if:
        # - input taxon concept has no distribution
        # - citation has no geo entity tags
        # - citation has geo entity tags outside of input taxon concept distribution
        # - distribution reassigned to this output overlaps with geo entity tags
        # citations not copied or modified here
        if !dc_ge_ids_to_reassign.empty? ||
          tc_distributions.empty? ||
          dc_geo_entities.empty?
          reassignment.reassignment_targets.build(nomenclature_change_output_id: output.id)
        end
      end
    end
    reassignment
  end

  def _build_reassignable_type_reassignment(reassignable_collection_name, input)
    reassignable_type = reassignable_collection_name.to_s.singularize.camelize
    input_class = input.reassignment_class
    input.send(:"#{reassignable_collection_name}_reassignments").first ||
      input.taxon_concept.send(reassignable_collection_name).limit(1).count > 0 &&
      input.reassignment_class.new(
        reassignable_type: reassignable_type,
        type: input_class.to_s
      ) || nil
  end

  def _build_common_names_reassignments(input, outputs)
    reassignment = _build_reassignable_type_reassignment(:taxon_commons, input)
    if reassignment
      if input.is_a?(NomenclatureChange::Input)
        _build_multiple_targets(reassignment, outputs)
      end
      input.reassignments << reassignment
    end
  end

  def _build_references_reassignments(input, outputs)
    reassignment = _build_reassignable_type_reassignment(:taxon_concept_references, input)
    if reassignment
      if input.is_a?(NomenclatureChange::Input)
        _build_multiple_targets(reassignment, outputs)
      end
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

  def in_year(event, lng)
    I18n.with_locale(lng) do
      I18n.translate(
        'in_year',
        year: event && event.effective_at.try(:year) || Date.today.year,
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
            default: ''
          )
        end
      end
    end
    result
  end

  def lower_ranks_cases(full_name, existing_name, existing_rank_name)
    if existing_name.blank?
      "<i>#{full_name}</i>"
    elsif LOWER_RANKS.include?(existing_rank_name) && existing_name.present?
      "<i>#{full_name}</i> (formerly <i>#{existing_name}</i>)"
    elsif HIGHER_RANKS.include?(existing_rank_name)
      "<i>#{full_name}</i> (formerly #{existing_name.upcase})"
    end
  end

  def higher_ranks_cases(full_name, existing_name, existing_rank_name)
    if existing_name.blank?
      full_name.upcase
    elsif LOWER_RANKS.include?(existing_rank_name) && existing_name.present?
      "#{full_name.upcase} (formerly <i>#{existing_name}</i>)"
    elsif HIGHER_RANKS.include?(existing_rank_name)
      "#{full_name.upcase} (formerly #{existing_name.upcase})"
    end
  end
end
