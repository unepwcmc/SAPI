# == Schema Information
#
# Table name: trade_validation_rules
#
#  id                :integer          not null, primary key
#  valid_values_view :string(255)
#  type              :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  format_re         :string(255)
#  run_order         :integer          not null
#  column_names      :string(255)
#  is_primary        :boolean          default(TRUE), not null
#  scope             :hstore
#  is_strict         :boolean          default(FALSE), not null
#

class Trade::TaxonConceptSourceValidationRule < Trade::InclusionValidationRule

  INVALID_KINGDOM_SOURCE = {
    'ANIMALIA' => ['A'],
    'PLANTAE' => ['C', 'R']
  }

  def validation_errors_for_shipment(shipment)
    return nil unless shipment.source && (
      shipment.taxon_concept &&
      shipment.taxon_concept.data['kingdom_name'] == 'Animalia' &&
      INVALID_KINGDOM_SOURCE['ANIMALIA'].include?(shipment.source.code) ||
      shipment.taxon_concept &&
      shipment.taxon_concept.data['kingdom_name'] == 'Plantae' &&
      INVALID_KINGDOM_SOURCE['PLANTAE'].include?(shipment.source.code)
    )
    error_message
  end

  private

  def matching_records_arel(table_name)
    s = Arel::Table.new("#{table_name}_view")
    tc = Arel::Table.new('taxon_concepts')
    t = Arel::Table.new('taxonomies')

    upper_kingdom_name = Arel::Nodes::NamedFunction.new(
      "UPPER",
      [Arel::SqlLiteral.new("taxon_concepts.data->'kingdom_name'")]
    )

    arel = s.project(
      s['*']
    ).join(tc).on(
      s['taxon_concept_id'].eq(tc['id'])
    ).join(t).on(
      tc['taxonomy_id'].eq(t['id']).and(t['name'].eq('CITES_EU'))
    ).where(
      upper_kingdom_name.eq('ANIMALIA').and(
        s['source_code'].in(
          INVALID_KINGDOM_SOURCE['ANIMALIA']
        )
      ).or(
        upper_kingdom_name.eq('PLANTAE').and(
          s['source_code'].in(
            INVALID_KINGDOM_SOURCE['PLANTAE']
          )
        )
      )
    )
  end
end
