module NomenclatureChange::StatusChange::ProcessorHelpers

  # Runs the subprocessors chain
  def run
    Rails.logger.warn("[#{@nc.type}] BEGIN")
    @subprocessors.each{ |processor| processor.run }
    Rails.logger.warn("[#{@nc.type}] END")
  end

  def reassignment_processor(output)
    return nil unless @input && output

    # if input is not one of outputs, that means it only acts as a template
    # for associations and reassignment processor should copy rather than
    # transfer associations
    transfer = [@primary_output, @secondary_output].compact.map(&:taxon_concept).include?(
      @input.taxon_concept
    )
    if transfer
      NomenclatureChange::ReassignmentProcessor.new(@input, output)
    else
      NomenclatureChange::ReassignmentCopyProcessor.new(@input, output)
    end

  end

  # Generate a summary based on the subprocessors chain
  def summary
    result = []
    @subprocessors.each{ |processor| result << processor.summary }
    result.flatten(1).compact
  end

end
