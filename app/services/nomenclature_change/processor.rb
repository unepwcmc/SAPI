class NomenclatureChange::Processor
  class ProcessingError < StandardError; end

  def initialize(nc)
    @nc = nc

    initialize_inputs_and_outputs

    @subprocessors = prepare_chain
  end

  # Runs the subprocessors chain
  def run
    Rails.logger.warn("[#{@nc.type}] BEGIN")

    @subprocessors.each do |processor|
      # Abort as soon as a subprocessor reports an unrecoverable failure.
      # Continuing would hide the original validation problem and surface a
      # later nil dereference in a different processor.
      raise ProcessingError, failure_message(processor) if processor.run == false
    end

    Rails.logger.warn("[#{@nc.type}] END")

    DocumentSearch.refresh_citations_and_documents

    DownloadsCache.clear
  end

  def summary
  end

private

  def failure_message(processor)
    "#{processor.class.name} failed while processing #{@nc.type} ##{@nc.id}"
  end

  def initialize_inputs_and_outputs; end

  def prepare_chain
    @subprocessors = []
  end
end
