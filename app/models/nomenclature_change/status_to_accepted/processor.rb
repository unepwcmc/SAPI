class NomenclatureChange::StatusToAccepted::Processor
  include NomenclatureChange::StatusChange::ProcessorHelpers

  def initialize(nc)
    @nc = nc
    @input = nc.input
    @primary_output = nc.primary_output
    @secondary_output = nc.secondary_output
    @subprocessors = prepare_chain
  end

  # Constructs an array of subprocessors which will be run in sequence
  # A subprocessor needs to respond to #run
  def prepare_chain
    chain = []
    output = @primary_output if @nc.needs_to_receive_associations?
    chain << NomenclatureChange::OutputTaxonConceptProcessor.new(@primary_output)

    if @input && output
      # if input is not one of outputs, that means it only acts as a template
      # for associations and reassignment processor should copy rather than
      # transfer associations
      transfer = [@primary_output, @secondary_output].compact.map(&:taxon_concept).include?(
        @input.taxon_concept
      )
      chain << if transfer
        NomenclatureChange::ReassignmentProcessor.new(@input, output)
      else
        NomenclatureChange::ReassignmentCopyProcessor.new(@input, output)
      end
    end
    chain << NomenclatureChange::StatusUpgradeProcessor.new(@primary_output, [])
    chain
  end

end
