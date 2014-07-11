class NomenclatureChange::ReassignmentProcessor

  def initialize(input, output, copy = false)
    @input = input
    @output = output
  end

  def run
    @input.reassignments.each do |reassignment|
      process_reassignment(reassignment)
    end
  end

  def process_reassignment(reassignment)
    Rails.logger.debug("Processing #{reassignment.reassignable_type} reassignment from #{@input.taxon_concept.full_name}")
    reassignment.reassignment_targets.select do |target|
      target.output.new_taxon_concept_id &&
        target.output.new_taxon_concept_id != @input.taxon_concept.id ||
        target.output.taxon_concept_id != @input.taxon_concept.id
    end.each do |target|
      if reassignment.reassignable_id.blank?
        @input.reassignables_by_class(reassignment.reassignable_type).each do |reassignable|
          process_transfer_to_target(target, reassignable)
        end
      else
        process_transfer_to_target(target, reassignment.reassignable)
      end
    end
  end

  # Each reassignable object implements find_duplicate,
  # which is called from here to make sure we're not adding a duplicate.
  def process_transfer_to_target(target, reassignable)
    new_taxon_concept = target.output.taxon_concept || target.output.new_taxon_concept
    Rails.logger.debug("Processing #{reassignable.class} #{reassignable.id} transfer to #{new_taxon_concept.full_name}")

    if target.reassignment.kind_of? NomenclatureChange::ParentReassignment
      reassignable.parent_id = new_taxon_concept.id
      reassignable.save
    elsif reassignable.class == 'Trade::Shipment'
      reassignable.taxon_concept_id = new_taxon_concept.id
      reassignable.save
      # TODO reported taxon concept id
    else
      transferred_object = reassignable.duplicates({
        taxon_concept_id: new_taxon_concept.id
      }).first || reassignable
      transferred_object.taxon_concept_id = new_taxon_concept.id
      transferred_object.save
    end
  end
end
