class NomenclatureChange::DeleteUnreassignedProcessor

  def initialize(input)
    @input = input
  end

  def run
    process_unreassigned_distributions
  end

  def process_unreassigned_distributions
    distributions = @input.distribution_reassignments.map{ |dr| 
      dr.reassignable if _is_input_reassignment(dr)
    }.compact
    
    #new_input_distributions = @input.taxon_concept.distributions.select do |d|
      #!distribution_reassignments_ids.include?(d.id)
    #end

    @input.taxon_concept.update_attributes({distributions: distributions})

  end

  def _is_input_reassignment(reassignment)
    reassignment.reassignment_targets.any? do |t|
      t.output.taxon_concept_id == @input.taxon_concept_id
    end
  end

  def summary
  end

end