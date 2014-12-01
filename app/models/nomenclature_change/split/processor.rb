class NomenclatureChange::Split::Processor < NomenclatureChange::Processor

  # Generate a summary based on the subprocessors chain
  def summary
    result = [[
      "#{@nc.input.taxon_concept.full_name} will be split into:",
      @nc.outputs.map(&:display_full_name)
    ]]
    @subprocessors.each{ |processor| result << processor.summary }
    result.flatten(1)
  end

  private

  # Constructs an array of subprocessors which will be run in sequence
  # A subprocessor needs to respond to #run
  def prepare_chain
    chain = []
    input_is_one_of_outputs = @outputs.reject{ |o| o.will_create_taxon? }.
      map(&:taxon_concept_id).include?(@input.taxon_concept_id)

    chain << NomenclatureChange::InputTaxonConceptProcessor.new(@input)
    @outputs.each_with_index do |output, idx|
      if @input.taxon_concept_id != output.taxon_concept_id
        chain << NomenclatureChange::OutputTaxonConceptProcessor.new(output)
      end
      if output.will_create_taxon?
        if ['A', 'N'].include?(output.name_status)
          chain << NomenclatureChange::StatusDowngradeProcessor.new(output)

          chain << NomenclatureChange::ReassignmentTransferProcessor.new(output, output)
        end
      elsif !output.will_create_taxon? && ['S', 'T'].include?(output.name_status)
        chain << NomenclatureChange::StatusUpgradeProcessor.new(output)
      end
      unless @input.taxon_concept_id == output.taxon_concept_id && !output.will_create_taxon?
        # if input is not one of outputs and this is the last output
        # transfer the associations rather than copy them
        transfer = !input_is_one_of_outputs && (idx == (@outputs.length - 1))
        if transfer
          chain << NomenclatureChange::ReassignmentTransferProcessor.new(@input, output)
        else
          chain << NomenclatureChange::ReassignmentCopyProcessor.new(@input, output)
        end
      end
    end
    unless input_is_one_of_outputs
      chain << NomenclatureChange::StatusDowngradeProcessor.new(@input, @outputs)
    end
    chain
  end

  def initialize_inputs_and_outputs
    @input = @nc.input
    @outputs = @nc.outputs
  end

end
