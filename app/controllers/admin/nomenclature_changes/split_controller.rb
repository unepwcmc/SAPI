class Admin::NomenclatureChanges::SplitController < Admin::NomenclatureChanges::BuildController
  steps(*NomenclatureChange::Split::STEPS)

  def show
    builder = NomenclatureChange::Split::Constructor.new(@nomenclature_change)

    case step
    when :inputs
      set_events
      set_taxonomy
      builder.build_input
    when :outputs
      set_taxonomy
      set_ranks
      builder.build_outputs
    when :notes
      builder.build_input_and_output_notes
    when :children
      builder.build_parent_reassignments
      skip_or_previous_step if @nomenclature_change.input.parent_reassignments.empty?
    when :names
      builder.build_name_reassignments
      skip_or_previous_step if @nomenclature_change.input.name_reassignments.empty?
    when :distribution
      builder.build_distribution_reassignments
      skip_or_previous_step if @nomenclature_change.input.distribution_reassignments.empty?
    when :legislation
      builder.build_legislation_reassignments
      skip_or_previous_step if @nomenclature_change.input.legislation_reassignments.empty?
    when :summary
      builder.build_document_reassignments

      processor = NomenclatureChange::Split::Processor.new(@nomenclature_change)
      @summary = processor.summary
    end

    render_wizard
  end

  def update
    @nomenclature_change.assign_attributes(
      begin
        nomenclature_change_split_params
      rescue ActionController::ParameterMissing
        # TODO: explain why we allow this to fail silently
        {}
      end.merge(
        {
          status: (step == steps.last ? NomenclatureChange::SUBMITTED : step.to_s)
        }
      )
    )

    success = @nomenclature_change.valid?

    case step
    when :inputs, :outputs
      unless success
        set_events
        set_taxonomy
        set_ranks
      end
    end

    render_wizard @nomenclature_change
  end

private

  def klass
    NomenclatureChange::Split
  end

  def nomenclature_change_split_params
    (
      input_attribute_names,
      output_attribute_names,
      output_parent_reassignment_attribute_names,
      output_reassignment_attribute_names,
    ) = common_nomenclature_change_attribute_names.values_at(
      :input_attribute_names,
      :output_attribute_names,
      :output_parent_reassignment_attribute_names,
      :output_reassignment_attribute_names,
    )

    params.expect(
      nomenclature_change_split: [
        :event_id, :status,
        ##
        # Note: `input` is singular, because split is one -> many
        input_attributes: [
          *input_attribute_names,
          parent_reassignments_attributes: [ output_parent_reassignment_attribute_names ],
          name_reassignments_attributes: [ output_reassignment_attribute_names ],
          distribution_reassignments_attributes: [ output_reassignment_attribute_names ],
          legislation_reassignments_attributes: [ output_reassignment_attribute_names ]
        ],
        ##
        # Note: `outputs` is plural, because split is one -> many
        outputs_attributes: [ output_attribute_names ]
      ]
    )
  end
end
