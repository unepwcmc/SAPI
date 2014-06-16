class NomenclatureChange::Split::Summarizer

  def initialize(split)
    @split = split
  end

  def summary
    res = [
      "#{@split.input.taxon_concept.full_name} will be split into:",
      @split.outputs.map do |output|
        res = [output.display_full_name]
        transformations = NomenclatureChange::Split::TransformationSummarizer.new(output).summary
        unless transformations.empty?
          res << [
            "The following transformations will be performed:",
            transformations
          ]
        end
        reassignments = NomenclatureChange::Split::ReassignmentSummarizer.new(@split.input, output).summary
        unless reassignments.empty?
          res << [
            "The following reassignments from #{@split.input.taxon_concept.full_name} will be performed:",
            reassignments
          ]
        end
        res
      end
    ]
  end

end