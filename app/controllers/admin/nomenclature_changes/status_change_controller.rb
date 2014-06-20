class Admin::NomenclatureChanges::StatusChangeController < Admin::NomenclatureChanges::BuildController

  steps *NomenclatureChange::StatusChange::STEPS

  def create
    @nomenclature_change = NomenclatureChange::StatusChange.new(:status => NomenclatureChange::NEW)
    if @nomenclature_change.save
      redirect_to wizard_path(steps.first, :nomenclature_change_id => @nomenclature_change.id)
    else
      redirect_to admin_nomenclature_changes_url, :alert => "Could not start a new nomenclature change"
    end
  end

  def show
    builder = NomenclatureChange::StatusChange::Constructor.new(@nomenclature_change)
    case step
    when :outputs
      set_events
      builder.build_outputs
    when :inputs
      builder.build_input
      skip_step if @nomenclature_change.input.nil? || @nomenclature_change.has_auto_input?
    when :notes
      builder.build_reassignments
      builder.build_output_notes
    when :summary
      @summary = NomenclatureChange::StatusChange::Summarizer.new(@nomenclature_change).summary
    end
    render_wizard
  end

  def update
    @nomenclature_change.assign_attributes(
      (params[:nomenclature_change_status_change] || {}).merge({
        :status => (step == steps.last ? NomenclatureChange::SUBMITTED : step.to_s)
      })
    )
    success = @nomenclature_change.valid?
    case step
    when :inputs
      set_events unless success
    end
    render_wizard @nomenclature_change
  end

end