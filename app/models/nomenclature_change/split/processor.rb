class NomenclatureChange::Split::Processor

  def initialize(nc)
    @nc = nc
    @input = nc.input
    @outputs = nc.outputs
  end

  def run
    Rails.logger.warn("[#{@nc.type}] BEGIN")
    @outputs.each{ |output| process_output(output) }
    process_input(@input)
    Rails.logger.warn("[#{@nc.type}] END")
  end

  private

  def process_output(output)
    Rails.logger.debug("[#{@nc.type}] Processing output #{output.display_full_name}")
    if output.taxon_concept.blank?
      process_new_name(output)
    elsif output.taxon_concept.full_name != output.display_full_name
      process_name_change(output)
    else
    end
  end

  def process_input(input)
    Rails.logger.debug("[#{@nc.type}] Processing input #{input.taxon_concept.full_name}")
    input.reassignments.each{ |reassignment| reassignment.process }
  end

  def process_new_name(output)
    tc = output.new_taxon_concept
    Rails.logger.debug("UPDATE NEW TAXON ID #{tc.id}")
    output.update_attributes({:new_taxon_concept_id => tc.id})
  end

  def process_name_change(output)
    tc = output.new_taxon_concept
    unless tc.save
      puts tc.inspect
    end
    #TODO perform status change
    Rails.logger.debug("UPDATE NEW TAXON ID #{tc.id}")
    output.update_attributes({:new_taxon_concept_id => tc.id})
  end

end
