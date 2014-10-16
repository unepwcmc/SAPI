class NomenclatureChange::Processor

  def initialize(nc)
    @nc = nc
    initialize_inputs_and_outputs
    @subprocessors = prepare_chain
  end


  # Runs the subprocessors chain
  def run
    Rails.logger.warn("[#{@nc.type}] BEGIN")
    @subprocessors.each{ |processor| processor.run }
    Rails.logger.warn("[#{@nc.type}] END")
  end

end