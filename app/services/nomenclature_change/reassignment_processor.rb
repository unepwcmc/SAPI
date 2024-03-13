class NomenclatureChange::ReassignmentProcessor

  def initialize(input, output)
    @input = input
    @output = output
  end

  def run
    process_reassignments(reassignments_to_process)
  end

  def reassignments_to_process
    if @input.is_a?(NomenclatureChange::Input)
      @input.reassignments.select do |r|
        # only consider reassignments that target this output
        r.reassignment_targets.map(&:nomenclature_change_output_id).include?(@output.id)
      end
    else
      @input.reassignments
    end
  end

  def process_reassignments(reassignments)
    reassignments.each do |reassignment|
      Rails.logger.debug("Processing #{reassignment.reassignable_type} reassignment from #{@input.taxon_concept.full_name}")
      if reassignment.reassignable_id.blank?
        process_reassignment_of_anonymous_reassignable(reassignment)
      else
        process_reassignment(reassignment, reassignment.reassignable)
      end
    end
  end

  def process_reassignment_of_anonymous_reassignable(reassignment)
    if reassignment.reassignable_type == 'Trade::Shipment'
      new_taxon_concept = @output.new_taxon_concept || @output.taxon_concept
      Trade::Shipment.where(taxon_concept_id: @input.taxon_concept_id)
                     .update_all(taxon_concept_id: new_taxon_concept.id)
    else
      @input.reassignables_by_class(reassignment.reassignable_type).each do |reassignable|
        process_reassignment(reassignment, reassignable)
      end
    end
  end

  def process_reassignment_to_target(target, reassignable); end

  def notes(reassigned_object, reassignment)
    {
      nomenclature_note_en: (reassigned_object.nomenclature_note_en || '') +
        reassignment.note_with_resolved_placeholders_en(@input, @output),
      nomenclature_note_es: (reassigned_object.nomenclature_note_es || '') +
        reassignment.note_with_resolved_placeholders_es(@input, @output),
      nomenclature_note_fr: (reassigned_object.nomenclature_note_fr || '') +
        reassignment.note_with_resolved_placeholders_fr(@input, @output),
      internal_notes: (reassigned_object.internal_notes || '') +
        reassignment.internal_note_with_resolved_placeholders(@input, @output)
    }
  end

  def summary
    [
      summary_line,
      NomenclatureChange::ReassignmentSummarizer.new(@input, @output).summary
    ]
  end

  protected

  def conflicting_listing_change_reassignment?(reassignment, reassignable)
    # this amazing condition to ensure that in cases when there are listing changes
    # coming from an upgraded taxon, they take precedence over any other
    # listing changes reassignments
    !reassignment.is_a?(NomenclatureChange::OutputReassignment) &&
    reassignable.is_a?(ListingChange) &&
    # if there is potential to reassign from upgraded taxon
    @output.taxon_concept && @output.new_taxon_concept &&
    reassignable.taxon_concept_id != @output.taxon_concept_id &&
    (
      reassignable.is_cites? && @output.taxon_concept.cites_listed ||
      reassignable.is_eu? && @output.taxon_concept.eu_listed
    )
  end

  def post_process(reassigned_object, object_before_reassignment)
    Rails.logger.warn("Reassignment post processing BEGIN")
    if reassigned_object.is_a?(TaxonConcept)
      resolver = NomenclatureChange::TaxonomicTreeNameResolver.new(reassigned_object, object_before_reassignment)
      resolver.process
    elsif reassigned_object.is_a?(TaxonRelationship)
      resolver = NomenclatureChange::TradeShipmentsResolver.new(reassigned_object, object_before_reassignment)
      resolver.process
    end
    Rails.logger.warn("Reassignment post processing END")
  end

end
