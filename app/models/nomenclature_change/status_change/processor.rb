class NomenclatureChange::StatusChange::Processor

  def initialize(nc)
    @nc = nc
    @input = nc.input
    @primary_output = nc.primary_output
    @secondary_output = nc.secondary_output
    @swap = @nc.is_swap?
  end

  def run
    Rails.logger.warn("[#{@nc.type}] BEGIN")
    Rails.logger.debug("[#{@nc.type}] Processing primary output #{@primary_output.display_full_name}")
    processor = NomenclatureChange::StatusChange::TransformationProcessor.new(@primary_output)
    processor.run
    if @swap
      Rails.logger.debug("[#{@nc.type}] Processing secondary output #{@secondary_output.display_full_name}")
      processor = NomenclatureChange::StatusChange::TransformationProcessor.new(@secondary_output)
      processor.run
    end
    output = if @nc.needs_to_relay_associations?
      @secondary_output
    elsif @nc.needs_to_receive_associations?
      @primary_output
    end
    if @input && output
      Rails.logger.debug("[#{@nc.type}] Processing reassignments from #{@input.taxon_concept.full_name}")
      processor = NomenclatureChange::ReassignmentProcessor.new(@input, output)
      processor.run
    end
    Rails.logger.warn("[#{@nc.type}] END")
  end

end
