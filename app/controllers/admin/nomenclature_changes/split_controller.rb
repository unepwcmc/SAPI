class Admin::NomenclatureChanges::SplitController < Admin::NomenclatureChanges::BuildController

  steps *NomenclatureChange::Split::STEPS

  def create
    @nomenclature_change = NomenclatureChange::Split.new(:status => NomenclatureChange::NEW)
    if @nomenclature_change.save
      redirect_to wizard_path(steps.first, :nomenclature_change_id => @nomenclature_change.id)
    else
      redirect_to admin_nomenclature_changes_url, :alert => "Could not start a new nomenclature change"
    end
  end

  def show
    builder = NomenclatureChange::Split::Constructor.new(@nomenclature_change)
    case step
    when :inputs
      set_events
      builder.build_input
    when :outputs
      builder.build_outputs
    when :children
      builder.build_parent_reassignments
    when :names
      builder.build_name_reassignments
    when :distribution
      builder.build_distribution_reassignments
    when :legislation
      builder.build_legislation_reassignments
    when :notes
      builder.build_common_names_reassignments
      builder.build_references_reassignments
      builder.build_input_and_output_notes
    when :summary
      @summary = NomenclatureChange::Split::Summarizer.new(@nomenclature_change).summary
    end
    render_wizard
  end

  def update
    success = if step == steps.last
      @nomenclature_change.submit
    else
      @nomenclature_change.update_attributes(
        (params[:nomenclature_change_split] || {}).merge({:status => step.to_s})
      )
    end
    case step
    when :inputs
      set_events unless success
    end
    render_wizard @nomenclature_change
  end

end