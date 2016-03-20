class NomenclatureChange::Lump::Processor < NomenclatureChange::Processor

  # Generate a summary based on the subprocessors chain
  def summary
    result = [[
      "The following taxa will be lumped into #{@nc.output.display_full_name}",
      @nc.inputs.map(&:taxon_concept).map(&:full_name)
    ]]
    @subprocessors.each{ |processor| result << processor.summary }
    result.flatten(1)
  end

  private

  # Constructs an array of subprocessors which will be run in sequence
  # A subprocessor needs to respond to #run
  def prepare_chain
    chain = []
    chain << NomenclatureChange::OutputTaxonConceptProcessor.new(@output)
    @inputs.each do |input|
      if !(input.taxon_concept_id == @output.taxon_concept_id && !@output.will_create_taxon?)
        chain << NomenclatureChange::InputTaxonConceptProcessor.new(input)
        chain << NomenclatureChange::CascadingNotesProcessor.new(input)
        chain << NomenclatureChange::ReassignmentTransferProcessor.new(input, @output)
        chain << NomenclatureChange::StatusDowngradeProcessor.new(input, [@output])
      end
    end
    chain << NomenclatureChange::CascadingNotesProcessor.new(@output)
    chain
  end

  def initialize_inputs_and_outputs
    @inputs = @nc.inputs
    @output = @nc.output
  end

end
