class Admin::NomenclatureChanges::StatusToAcceptedController < Admin::NomenclatureChanges::BuildController
  steps(*NomenclatureChange::StatusToAccepted::STEPS)

  def show
    builder = klass::Constructor.new(@nomenclature_change)
    case step
    when :primary_output
      set_events
      set_taxonomy
      set_ranks
      builder.build_primary_output
    when :summary
      processor = klass::Processor.new(@nomenclature_change)
      @summary = processor.summary
    end
    render_wizard
  end

  def update
    @nomenclature_change.assign_attributes(
      begin
        nomenclature_change_status_to_accepted_params
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
    when :primary_output
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
    NomenclatureChange::StatusToAccepted
  end

  def nomenclature_change_status_to_accepted_params
    (
      input_attribute_names,
      output_attribute_names,
      output_reassignment_attribute_names,
      parent_reassignments_attribute_names,
    ) = common_nomenclature_change_attribute_names.values_at(
      :input_attribute_names,
      :output_attribute_names,
      :output_reassignment_attribute_names,
      :parent_reassignments_attribute_names,
    )

    params.expect(
      nomenclature_change_status_to_accepted: [
        :created_by_id, :updated_by_id, :event_id, :status,
        primary_output_attributes: output_attribute_names,
        secondary_output_attributes: output_attribute_names,
        input_attributes: [
          *input_attribute_names,
          parent_reassignments_attributes: [ parent_reassignments_attribute_names ],
          name_reassignments_attributes: [ output_reassignment_attribute_names ],
          distribution_reassignments_attributes: [ output_reassignment_attribute_names ],
          legislation_reassignments_attributes: [ output_reassignment_attribute_names ]
        ]
      ]
    )
  end
end
