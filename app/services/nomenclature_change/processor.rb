class NomenclatureChange::Processor

  def initialize(nc)
    @nc = nc
    initialize_inputs_and_outputs
    @subprocessors = prepare_chain
  end

  # Runs the subprocessors chain
  def run
    Rails.logger.warn("[#{@nc.type}] BEGIN")
    @subprocessors.each { |processor| processor.run }
    Rails.logger.warn("[#{@nc.type}] END")
    DocumentSearch.refresh_citations_and_documents
    DownloadsCache.clear
  end

  def summary
  end

  private

  def initialize_inputs_and_outputs; end

  def prepare_chain
    @subprocessors = []
  end

end
