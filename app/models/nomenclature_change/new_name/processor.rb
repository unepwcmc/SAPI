class NomenclatureChange::NewName::Processor < NomenclatureChange::Processor

  def summary
    result = []
    @subprocessors.each{ |processor| result << processor.summary }
    result.flatten(1)
  end

  private

  def prepare_chain
    chain = []
    chain << NomenclatureChange::OutputTaxonConceptProcessor.new(@output)
  end

  def initialize_inputs_and_outputs
    @output = @nc.output
  end
  
end
