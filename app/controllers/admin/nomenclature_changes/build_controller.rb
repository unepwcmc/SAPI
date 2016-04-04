class Admin::NomenclatureChanges::BuildController < Admin::AdminController
  include Wicked::Wizard

  before_filter :set_nomenclature_change, :only => [:show, :update, :destroy]
  before_filter :redirect_in_production
  before_filter :set_back, only: [:update]

  def finish_wizard_path
    admin_nomenclature_changes_path
  end

  def create
    @nomenclature_change = klass.new(:status => NomenclatureChange::NEW)
    if @nomenclature_change.save
      redirect_to wizard_path(steps.first, :nomenclature_change_id => @nomenclature_change.id)
    else
      redirect_to admin_nomenclature_changes_url, :alert => "Could not start a new nomenclature change"
    end
  end

  private

  def set_nomenclature_change
    @nomenclature_change = NomenclatureChange.find(params[:nomenclature_change_id])
  end

  def set_events
    @events = CitesCop.order('effective_at DESC')
  end

  def set_taxonomy
    @taxonomy = Taxonomy.find_by_name(Taxonomy::CITES_EU)
  end

  def skip_or_previous_step
    if params[:back] || session[:back]
      jump_to(previous_step)
      session[:back] = true
    else
      skip_step
    end
  end

  private
  def klass
    NomenclatureChange
  end

  def set_back
    session[:back] = false
  end

end
