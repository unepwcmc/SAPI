class NomenclatureChange::StatusToAccepted::Processor
  include NomenclatureChange::StatusChange::ProcessorHelpers

  def initialize(nc)
    @nc = nc
    initialize_inputs_and_outputs
    @subprocessors = prepare_chain
  end

  def initialize_inputs_and_outputs
    @input = @nc.input
    @primary_output = @nc.primary_output
    @secondary_output = @nc.secondary_output
  end

  # Constructs an array of subprocessors which will be run in sequence
  # A subprocessor needs to respond to #run
  def prepare_chain
    chain = []
    output = @primary_output if @nc.needs_to_receive_associations?
    chain << NomenclatureChange::OutputTaxonConceptProcessor.new(@primary_output)

    chain << reassignment_processor(output)

    chain << NomenclatureChange::StatusUpgradeProcessor.new(@primary_output, [])
    chain.compact
  end

end
