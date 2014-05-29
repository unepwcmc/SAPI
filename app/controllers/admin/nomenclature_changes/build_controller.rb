class Admin::NomenclatureChanges::BuildController < Admin::AdminController
  include Wicked::Wizard

  before_filter :set_nomenclature_change, :only => [:show, :update, :destroy]

  steps :inputs, :outputs, :summary

  def show
    case step
    when :inputs
      set_events
      @nomenclature_change.nomenclature_change_inputs.build(:is_input => true)
    when :outputs
      @nomenclature_change.nomenclature_change_outputs.build(:is_input => false)
    end
    render_wizard
  end

  def update
    success = @nomenclature_change.update_attributes(params[:nomenclature_change])
    case step
    when :inputs
      set_events unless success
    end
    render_wizard @nomenclature_change
  end

  def create
    @nomenclature_change = NomenclatureChange.create
    redirect_to wizard_path(steps.first, :nomenclature_change_id => @nomenclature_change.id)
  end

  def destroy
    @nomenclature_change.destroy
    redirect_to admin_nomenclature_changes_path
  end

  def finish_wizard_path
    admin_nomenclature_changes_path
  end

  private

  def set_nomenclature_change
    @nomenclature_change = NomenclatureChange.find(params[:nomenclature_change_id])
  end

  def set_events
    @events = CitesCop.order('effective_at DESC')
  end

end