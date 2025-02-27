class Api::V1::EuDecisionsController < ApplicationController
  # makes params available to the ActiveModel::Serializers
  serialization_scope :view_context

  def index
    @eu_decisions = eu_decision_search(sanitized_params)
    render json: @eu_decisions,
      each_serializer: CaptiveBreeding::EuDecisionSerializer
  end

private

  def permitted_params
    params.permit(taxon_concept_ids: [], geo_entity_ids: [])
  end

  def eu_decision_search(params)
    list = EuDecision.from(
      'api_eu_decisions_view AS eu_decisions'
    ).select(
      eu_decision_select_attrs
    ).joins(
      'LEFT JOIN eu_suspensions_applicability_view v ON eu_decisions.id = v.id'
    ).order(
      Arel.sql(
        <<-SQL.squish
          geo_entity_en->>'name' ASC,
          start_date DESC
        SQL
      )
    )

    list = list.where(eu_decisions: { taxon_concept_id: params['taxon_concept_ids'] }) if params['taxon_concept_ids'].present?
    list = list.where(eu_decisions: { geo_entity_id: params['geo_entity_ids'] }) if params['geo_entity_ids'].present?

    list.all
  end

  def eu_decision_select_attrs
    string = <<-SQL.squish
      eu_decisions.notes,
      eu_decisions.start_date,
      v.original_start_date_formatted,
      eu_decisions.is_current,
      eu_decisions.geo_entity_id,
      eu_decisions.start_event_id,
      eu_decisions.term_id,
      eu_decisions.source_id,
      eu_decisions.eu_decision_type_id,
      eu_decisions.term_id,
      eu_decisions.source_id,
      eu_decisions.nomenclature_note_en,
      eu_decisions.nomenclature_note_fr,
      eu_decisions.nomenclature_note_es,
      eu_decision_type,
      srg_history,
      start_event,
      end_event,
      geo_entity_en,
      taxon_concept,
      term_en,
      source_en
    SQL

    current_user ? "#{string}, private_url" : string
  end

  def sanitized_params
    filters =
      permitted_params.to_h.inject({}) do |h, (k, v)|
        h[k] = v.reject(&:empty?).map!(&:to_i)

        h
      end
    filters
  end
end
