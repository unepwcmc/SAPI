module NomenclatureChange::StatusChange::ProcessorHelpers

  # Runs the subprocessors chain
  def run
    Rails.logger.warn("[#{@nc.type}] BEGIN")
    @subprocessors.each{ |processor| processor.run }
    Rails.logger.warn("[#{@nc.type}] END")
  end

  # Generate a summary based on the subprocessors chain
  def summary
    result = []
    @subprocessors.each{ |processor| result << processor.summary }
    result.flatten(1).compact
  end

end
