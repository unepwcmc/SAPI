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
      shipment.taxon_concept.data['kingdom_name'] == 'Plantae' &&
      INVALID_KINGDOM_SOURCE['PLANTAE'].include?(shipment.source.code)
    )
    error_message
  end

  private

  # Returns matching records grouped by column_names to return the count of
  # specific errors and ids of matching records
  def matching_records_grouped(table_name)
    sandbox_klass = Trade::SandboxTemplate.ar_klass(table_name)
    sandbox_klass.
      joins(<<-SQL
            INNER JOIN taxon_concepts ON taxon_concepts.full_name = species_name
            INNER JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
           SQL
      ).where(<<-SQL
          (
            UPPER(taxon_concepts.data->'kingdom_name') = 'ANIMALIA'
              AND source_code IN (#{INVALID_KINGDOM_SOURCE['ANIMALIA'].map{|c| "'#{c}'"}.join(',')})
          ) OR
          (
            UPPER(taxon_concepts.data->'kingdom_name') = 'PLANTAE'
              AND source_code IN (#{INVALID_KINGDOM_SOURCE['PLANTAE'].map{|c| "'#{c}'"}.join(',')})
          )
        SQL
     ).
     where(:taxonomies => {:name => Taxonomy::CITES_EU}).
     select(['COUNT(*) AS error_count', "ARRAY_AGG(#{table_name}.id) AS matching_records_ids",
            'species_name', 'source_code']).
     group('species_name, source_code')
  end
end
