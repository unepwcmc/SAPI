class Admin::NomenclatureChanges::StatusToSynonymController < Admin::NomenclatureChanges::BuildController

  steps *NomenclatureChange::StatusToSynonym::STEPS

  def show
    builder = klass::Constructor.new(@nomenclature_change)
    case step
    when :primary_output
      set_events
      set_taxonomy
      builder.build_primary_output
    when :relay
      skip_or_previous_step unless @nomenclature_change.needs_to_relay_associations?
      set_taxonomy
      builder.build_secondary_output
    when :accepted_name
      skip_or_previous_step unless @nomenclature_change.requires_accepted_name_assignment?
      set_taxonomy
      builder.build_secondary_output
    when :legislation
      builder.build_legislation_reassignments
      skip_or_previous_step if @nomenclature_change.input.nil? || @nomenclature_change.input.legislation_reassignments.empty?
    when :summary
      processor = klass::Processor.new(@nomenclature_change)
      @summary = processor.summary
    end
    render_wizard
  end

  def update
    @nomenclature_change.assign_attributes(
      (params[:nomenclature_change_status_to_synonym] || {}).merge({
        :status => (step == steps.last ? NomenclatureChange::SUBMITTED : step.to_s)
      })
    )
    success = @nomenclature_change.valid?
    case step
    when :primary_output
      unless success
        set_events
        set_taxonomy
      end
    when :relay, :accepted_name
      set_taxonomy unless success
    end
    render_wizard @nomenclature_change
  end

  private

  def klass
    NomenclatureChange::StatusToSynonym
  end

end
