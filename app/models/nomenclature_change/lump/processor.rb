class NomenclatureChange::Lump::Processor

  def initialize(nc)
    @nc = nc
    initialize_inputs_and_outputs
    @subprocessors = prepare_chain
  end

  def initialize_inputs_and_outputs
    @inputs = @nc.inputs
    @output = @nc.output
  end

  # Constructs an array of subprocessors which will be run in sequence
  # A subprocessor needs to respond to #run
  def prepare_chain
    chain = []
    chain << NomenclatureChange::OutputTaxonConceptProcessor.new(@output)
    @inputs.each do |input|
      unless input.taxon_concept_id == @output.taxon_concept_id && !@output.will_create_taxon?
        chain << NomenclatureChange::ReassignmentTransferProcessor.new(input, @output)
        chain << NomenclatureChange::StatusDowngradeProcessor.new(input, [@output])
        chain << NomenclatureChange::InputTaxonConceptProcessor.new(input)
      end
    end
    chain
  end

  # Runs the subprocessors chain
  def run
    Rails.logger.warn("[#{@nc.type}] BEGIN")
    @subprocessors.each{ |processor| processor.run }
    Rails.logger.warn("[#{@nc.type}] END")
  end

  # Generate a summary based on the subprocessors chain
  def summary
    result = [[
      "The following taxa will be lumped into #{@nc.output.taxon_concept.full_name}",
      @nc.inputs.map(&:taxon_concept).map(&:full_name)
    ]]
    @subprocessors.each{ |processor| result << processor.summary }
    result.flatten(1)
  end

end
