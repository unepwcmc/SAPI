class NomenclatureChange::StatusSwap::Processor
  include NomenclatureChange::StatusChange::ProcessorHelpers

  def initialize(nc)
    @nc = nc
    @input = nc.input
    @primary_output = nc.primary_output
    @secondary_output = nc.secondary_output
    @primary_old_status = @primary_output.taxon_concept.name_status.dup
    @primary_new_status = @primary_output.new_name_status
    @secondary_old_status = @secondary_output && @secondary_output.taxon_concept.name_status.dup
    @subprocessors = prepare_chain
  end

  # Constructs an array of subprocessors which will be run in sequence
  # A subprocessor needs to respond to #run
  def prepare_chain
    chain = []
    output = if @nc.needs_to_relay_associations?
      @secondary_output
    elsif @nc.needs_to_receive_associations?
      @primary_output
    end
    chain << NomenclatureChange::OutputTaxonConceptProcessor.new(@primary_output)
    chain << NomenclatureChange::OutputTaxonConceptProcessor.new(@secondary_output)

    chain << reassignment_processor(output)

    chain << if @primary_output.new_name_status == 'A'
      linked_names = @secondary_output ? [@secondary_output] : []
      NomenclatureChange::StatusUpgradeProcessor.new(@primary_output, linked_names)
    else
      accepted_names = @secondary_output ? [@secondary_output] : []
      NomenclatureChange::StatusDowngradeProcessor.new(@primary_output, accepted_names)
    end
    chain.compact
  end

end
