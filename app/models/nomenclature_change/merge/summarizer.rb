class NomenclatureChange::Merge::Summarizer

  def initialize(merge)
    @merge = merge
  end

  def summary
    res = [
      "#{@merge.input.taxon_concept.full_name} will be merge into:",
      @merge.outputs.map do |output|
        res = [output.display_full_name]
        transformations = NomenclatureChange::Merge::TransformationSummarizer.new(output).summary
        unless transformations.empty?
          res << [
            "The following transformations will be performed:",
            transformations
          ]
        end
        reassignments = NomenclatureChange::Merge::ReassignmentSummarizer.new(@merge.input, output).summary
        unless reassignments.empty?
          res << [
            "The following reassignments from #{@merge.input.taxon_concept.full_name} will be performed:",
            reassignments
          ]
        end
        res
      end
    ]
  end

end
