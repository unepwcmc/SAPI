class Admin::NomenclatureChanges::BuildController < Admin::AdminController
  include Wicked::Wizard

  before_action :set_nomenclature_change, only: [ :show, :update, :destroy ]
  before_action :unset_back, only: [ :update ]
  before_action :authorise_finish, only: [ :update ]

  def finish_wizard_path
    admin_nomenclature_changes_path
  end

  def show
    raise NoMethodError
  end

  def create
    @nomenclature_change = klass.new()
    @nomenclature_change.status = NomenclatureChange::NEW
    if @nomenclature_change.save
      redirect_to wizard_path(steps.first, nomenclature_change_id: @nomenclature_change.id)
    else
      redirect_to admin_nomenclature_changes_url, alert: 'Could not start a new nomenclature change'
    end
  end


  def update
    raise NoMethodError
  end

  def destroy
    raise NoMethodError
  end

protected
  def common_nomenclature_change_attribute_names
    input_attribute_names = [
      :id, :_destroy,
      :nomenclature_change_id, :taxon_concept_id,
      :note_en, :note_es, :note_fr, :internal_note
    ]

    output_attribute_names = [
      :id, :_destroy,
      :nomenclature_change_id, :taxon_concept_id,
      :new_taxon_concept_id, :rank_id, :new_scientific_name, :new_author_year,
      :new_name_status, :new_parent_id, :new_rank_id, :taxonomy_id,
      :note_en, :note_es, :note_fr, :internal_note, :is_primary_output,
      :output_type, :created_by_id, :updated_by_id,
      tag_list: []
    ]

    reassignment_attribute_names = [
      :id, :_destroy,
      :type, :reassignable_id, :reassignable_type,
      :nomenclature_change_input_id, :nomenclature_change_output_id,
      :note_en, :note_es, :note_fr, :internal_note
    ]

    reassignment_target_attribute_names = [
      :id, :_destroy,
      :nomenclature_change_output_id,
      :nomenclature_change_reassignment_id,
      :note
    ]

    parent_reassignments_attribute_names = [
      *reassignment_attribute_names,
      reassignment_target_attributes: [ reassignment_target_attribute_names ]
    ]

    output_parent_reassignment_attribute_names = [
      *parent_reassignments_attribute_names,
      output_ids: []
    ]

    output_reassignment_attribute_names = [
      *reassignment_attribute_names,
      output_ids: []
    ]

    {
      input_attribute_names:,
      output_attribute_names:,
      output_parent_reassignment_attribute_names:,
      output_reassignment_attribute_names:,
      parent_reassignments_attribute_names:,
      reassignment_attribute_names:,
      reassignment_target_attribute_names:
    }
  end

private

  def set_nomenclature_change
    @nomenclature_change = NomenclatureChange.find(params[:nomenclature_change_id])
  end

  def set_events
    @events = CitesCop.order(effective_at: :desc)
  end

  def set_taxonomy
    @taxonomy = Taxonomy.find_by(name: Taxonomy::CITES_EU)
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

  def klass
    NomenclatureChange
  end

  def unset_back
    session[:back] = false
  end
end
