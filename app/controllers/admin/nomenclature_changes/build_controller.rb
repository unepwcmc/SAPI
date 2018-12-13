class Admin::NomenclatureChanges::BuildController < Admin::AdminController
  include Wicked::Wizard

  before_filter :set_nomenclature_change, :only => [:show, :update, :destroy]
  before_filter :unset_back, only: [:update]
  before_filter :authorise_finish, only: [:update]

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

  def set_ranks
    @ranks = Rank.order(:taxonomic_position)
  end

  def skip_or_previous_step
    if params[:back] || session[:back]
      jump_to(previous_step)
      session[:back] = true
    else
      skip_step
    end
  end

  def authorise_finish
    if step == steps.last && (current_user.is_secretariat? || !current_user.is_active?)
      raise CanCan::AccessDenied
    end
  end

  private

  def klass
    NomenclatureChange
  end

  def unset_back
    session[:back] = false
  end

end
