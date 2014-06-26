class Admin::NomenclatureChanges::LumpController < Admin::NomenclatureChanges::BuildController

  steps *NomenclatureChange::Lump::STEPS

  def create
    @nomenclature_change = NomenclatureChange::Lump.new(:status => NomenclatureChange::NEW)
    if @nomenclature_change.save
      redirect_to wizard_path(steps.first, :nomenclature_change_id => @nomenclature_change.id)
    else
      redirect_to admin_nomenclature_changes_url, :alert => "Could not start a new nomenclature change"
    end
  end

  def show
    builder = NomenclatureChange::Lump::Constructor.new(@nomenclature_change)
    case step
    when :inputs
      set_events
      builder.build_input
    when :outputs
      builder.build_outputs
    when :notes
      builder.build_common_names_reassignments
      builder.build_references_reassignments
      builder.build_input_and_output_notes
    when :children
      builder.build_parent_reassignments
      skip_step if @nomenclature_change.input.parent_reassignments.empty?
    when :names
      builder.build_name_reassignments
      skip_step if @nomenclature_change.input.name_reassignments.empty?
    when :distribution
      builder.build_distribution_reassignments
      skip_step if @nomenclature_change.input.distribution_reassignments.empty?
    when :legislation
      builder.build_legislation_reassignments
      skip_step if @nomenclature_change.input.legislation_reassignments.empty?
    when :summary
      @summary = NomenclatureChange::Lump::Summarizer.new(@nomenclature_change).summary
    end
    render_wizard
  end

  def update
    @nomenclature_change.assign_attributes(
      (params[:nomenclature_change_lump] || {}).merge({
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
