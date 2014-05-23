class Admin::NomenclatureChanges::BuildController < ApplicationController
  include Wicked::Wizard

  steps :inputs, :summary

  def show
    @nomenclature_change = NomenclatureChange.find(params[:nomenclature_change_id])
    @events = CitesCop.order('effective_at DESC')
    render_wizard
  end


  def update
    @nomenclature_change = NomenclatureChange.find(params[:nomenclature_change_id])
    @nomenclature_change.update_attributes(params[:nomenclature_change])
    render_wizard @nomenclature_change
  end


  def create
    @nomenclature_change = NomenclatureChange.create
    redirect_to wizard_path(steps.first, :nomenclature_change_id => @nomenclature_change.id)
  end

  def finish_wizard_path
    admin_nomenclature_changes_path
  end
end