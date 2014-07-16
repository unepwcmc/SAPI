class NomenclatureChange::Split::Processor

  def initialize(nc)
    @nc = nc
    @input = nc.input
    @outputs = nc.outputs
    @subprocessors = prepare_chain
  end

  # Constructs an array of subprocessors which will be run in sequence
  # A subprocessor needs to respond to #run
  def prepare_chain
    chain = []
    input_is_one_of_outputs = @outputs.reject{ |o| o.new_full_name }.
      map(&:taxon_concept_id).include?(@input.taxon_concept_id)
    @outputs.each_with_index do |output, idx|
      chain << NomenclatureChange::TaxonConceptUpdateProcessor.new(output)
      if output.new_taxon_concept
        if ['A', 'N'].include?(output.name_status)
          chain << NomenclatureChange::StatusDowngradeProcessor.new(output)
        end
        # TODO output taxon_concept becomes synonym of new_taxon_concept
      elsif output.new_taxon_concept.nil? && ['S', 'T'].include?(output.name_status)
        chain << NomenclatureChange::StatusUpgradeProcessor.new(output)
      end
      unless @input.taxon_concept_id == output.taxon_concept_id && output.new_full_name.nil?
        # if input is not one of outputs and this is the last output
        # transfer the associations rather than copy them
        transfer = !input_is_one_of_outputs && (idx == (@outputs.length - 1))
        chain << if transfer
          NomenclatureChange::ReassignmentProcessor.new(@input, output)
        else
          NomenclatureChange::ReassignmentCopyProcessor.new(@input, output)
        end
      end
    end
    unless input_is_one_of_outputs
      chain << NomenclatureChange::StatusDowngradeProcessor.new(@input, @outputs)
    end
    chain
  end

  # Runs the subprocessors chain
  def run
    Rails.logger.warn("[#{@nc.type}] BEGIN")
    @subprocessors.each{ |processor| processor.run }
    Rails.logger.warn("[#{@nc.type}] END")
  end

end
