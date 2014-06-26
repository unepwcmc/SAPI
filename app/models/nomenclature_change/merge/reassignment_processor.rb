class NomenclatureChange::Merge::ReassignmentProcessor

  def initialize(input, output)
    @input = input
    @output = output
    @nc = output.nomenclature_change
  end

  def run
    @input.reassignments.each do |reassignment|
      process_reassignment(reassignment)
    end
  end

  private

  # all objects of reassignable_type that are linked to input taxon
  def reassignables_by_class(reassignable_type)
    Object::const_get(reassignable_type).where(
      :taxon_concept_id => @input.taxon_concept.id
    )
  end

  def process_reassignment(reassignment)
    Rails.logger.debug("Processing #{reassignment.reassignable_type} reassignment from #{@input.taxon_concept.full_name}")
    reassignment.reassignment_targets.select do |target|
      target.output != @input
    end.each do |target|
      if reassignment.reassignable_id.blank?
        reassignables_by_class(reassignment.reassignable_type).each do |reassignable|
          process_target(target, reassignable)
        end
      else
        process_target(target, reassignment.reassignable)
      end
    end
    unless @nc.outputs.include?(@input) || reassignment.kind_of?(NomenclatureChange::ParentReassignment)
      # input is not part of the merge
      # delete original association
      Rails.logger.warn("Deleting #{reassignment.reassignable_type} (id=#{reassignment.reassignable_id}) from #{@input.taxon_concept.full_name}")
      if reassignment.reassignable_id.blank?
        reassignables_by_class(reassignment.reassignable_type).each do |reassignable|
          reassignable.destroy
        end
      else
        reassignment.reassignable.destroy
      end
    end
  end

  def process_target(target, reassignable)
    new_taxon_concept = target.output.taxon_concept || target.output.new_taxon_concept
    Rails.logger.debug("Processing reassignment to #{new_taxon_concept.full_name}")

    # TODO for listing changes this needs to copy: annotations, listing distributions and exceptions
    # TODO for distributions this needs to copy distribution references
    # TODO for trade restrictions this needs to copy purpose / source / term links
    if target.reassignment.kind_of? NomenclatureChange::ParentReassignment
      reassignable.parent_id = new_taxon_concept.id
      reassignable.save
    else
      new_object = reassignable.dup
      new_object.taxon_concept_id = new_taxon_concept.id
      new_object.save
    end
  end

end
