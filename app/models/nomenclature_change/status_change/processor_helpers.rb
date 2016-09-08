module NomenclatureChange::StatusChange::ProcessorHelpers

  def reassignment_processor(output)
    return nil unless @input && output

    # if input is not one of outputs, that means it only acts as a template
    # for associations and reassignment processor should copy rather than
    # transfer associations; if it is one of the outputs it is probably a swap
    transfer = [@primary_output, @secondary_output].compact.map(&:taxon_concept).include?(
      @input.taxon_concept
    )
    if transfer
      NomenclatureChange::ReassignmentTransferProcessor.new(@input, output)
    else
      NomenclatureChange::ReassignmentCopyProcessor.new(@input, output)
    end
  end

  # Generate a summary based on the subprocessors chain
  def summary
    result = []
    @subprocessors.each { |processor| result << processor.summary }
    result.flatten(1).compact
  end

end
