class Admin::NomenclatureChanges::StatusToAcceptedController < Admin::NomenclatureChanges::BuildController

  steps *NomenclatureChange::StatusToAccepted::STEPS

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
      (nomenclature_change_status_to_accepted_params || {}).merge({
        :status => (step == steps.last ? NomenclatureChange::SUBMITTED : step.to_s)
      })
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
    params.require(:nomenclature_change_status_to_accepted).permit(
      :created_by_id, :updated_by_id, :event_id, :status,
      primary_output_attributes: [
        :id, :_destroy,
        :nomenclature_change_id, :taxon_concept_id,
        :new_taxon_concept_id, :rank_id, :new_scientific_name, :new_author_year,
        :new_name_status, :new_parent_id, :new_rank_id, :taxonomy_id,
        :note_en, :note_es, :note_fr, :internal_note, :is_primary_output,
        :output_type, :tag_list, :created_by_id, :updated_by_id
        # app/models/nomenclature_change/output.rb does not have `accepts_nested_attributes_for`, so
        # xxx_attributes suppose not in-use.
        # :parent_reassignments_attributes,
        # :name_reassignments_attributes,
        # :distribution_reassignments_attributes,
        # :legislation_reassignments_attributes,
      ],
      secondary_output_attributes: [
        :id, :_destroy,
        :nomenclature_change_id, :taxon_concept_id,
        :new_taxon_concept_id, :rank_id, :new_scientific_name, :new_author_year,
        :new_name_status, :new_parent_id, :new_rank_id, :taxonomy_id,
        :note_en, :note_es, :note_fr, :internal_note, :is_primary_output,
        :output_type, :tag_list, :created_by_id, :updated_by_id
        # app/models/nomenclature_change/output.rb does not have `accepts_nested_attributes_for`, so
        # xxx_attributes suppose not in-use.
        # :parent_reassignments_attributes,
        # :name_reassignments_attributes,
        # :distribution_reassignments_attributes,
        # :legislation_reassignments_attributes,
      ],
      input_attributes: [
        :id, :_destroy,
        :nomenclature_change_id, :taxon_concept_id,
        :note_en, :note_es, :note_fr, :internal_note,
        parent_reassignments_attributes: [
          :id, :_destroy,
          :type, :reassignable_id, :reassignable_type,
          :nomenclature_change_input_id, :nomenclature_change_output_id,
          :note_en, :note_es, :note_fr, :internal_note, :output_ids,
          reassignment_target_attributes: [
            :id, :_destroy,
            :nomenclature_change_output_id,
            :nomenclature_change_reassignment_id, :note
          ]
        ],
        name_reassignments_attributes: [
          :id, :_destroy,
          :type, :reassignable_id, :reassignable_type,
          :nomenclature_change_input_id, :nomenclature_change_output_id,
          :note_en, :note_es, :note_fr, :internal_note, :output_ids
        ],
        distribution_reassignments_attributes: [
          :id, :_destroy,
          :type, :reassignable_id, :reassignable_type,
          :nomenclature_change_input_id, :nomenclature_change_output_id,
          :note_en, :note_es, :note_fr, :internal_note, :output_ids
        ],
        legislation_reassignments_attributes: [
          :id, :_destroy,
          :type, :reassignable_id, :reassignable_type,
          :nomenclature_change_input_id, :nomenclature_change_output_id,
          :note_en, :note_es, :note_fr, :internal_note, :output_ids
        ]
      ]
    )
  end
end
