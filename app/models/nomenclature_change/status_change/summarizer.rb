class NomenclatureChange::StatusChange::Summarizer

  def initialize(status_change)
    @status_change = status_change
  end

  def summary
    res = [@status_change.primary_output, @status_change.secondary_output].
    compact.map do |output|
      res = [output.display_full_name]
      transformations = NomenclatureChange::Split::TransformationSummarizer.new(output).summary
      unless transformations.empty?
        res << [
          "The following transformations will be performed:",
          transformations
        ]
      end
      reassignments = @status_change.input &&
        NomenclatureChange::ReassignmentSummarizer.new(@status_change.input, output).summary || []
      unless reassignments.empty?
        res << [
          "The following reassignments from #{@status_change.input.taxon_concept.full_name} will be performed:",
          reassignments
        ]
      end
      res
    end
  end

end