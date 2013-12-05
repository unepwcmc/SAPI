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

  def validation_errors(annual_report_upload)
    matching_records_grouped(annual_report_upload.sandbox.table_name).map do |mr|
      error_selector = error_selector(mr, annual_report_upload.point_of_view)
      Trade::ValidationError.new(
          :error_message => error_message(error_selector),
          :annual_report_upload_id => annual_report_upload.id,
          :validation_rule_id => self.id,
          :error_count => mr.error_count,
          :error_selector => error_selector,
          :matching_records_ids => parse_pg_array(mr.matching_records_ids),
          :is_primary => self.is_primary
      )
    end
  end

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

  # Returns a hash with column values to be used to select invalid rows.
  # e.g.
  # {
  #    :species_name => 'Loxodonta africana',
  #    :source_code => 'A'
  #
  # }
  # Expects a single grouped matching record.
  # TODO this is the same as for InclusionValidationRule: could this
  # class inherit from there?
  # def error_selector(matching_record)
  #   res = {}
  #   column_names.each do |cn|
  #     res[cn] = matching_record.send(cn)
  #   end
  #   res
  # end

  # Returns matching records grouped by column_names to return the count of
  # specific errors and ids of matching records
  def matching_records_grouped(table_name)
    sandbox_klass = Trade::SandboxTemplate.ar_klass(table_name)
    sandbox_klass.
      joins(<<-SQL
            INNER JOIN taxon_concepts ON taxon_concepts.full_name = SQUISH_NULL(species_name)
            INNER JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
           SQL
      ).where(<<-SQL
          (
            UPPER(taxon_concepts.data->'kingdom_name') = 'ANIMALIA'
              AND SQUISH_NULL(source_code) IN (#{INVALID_KINGDOM_SOURCE['ANIMALIA'].map{|c| "'#{c}'"}.join(',')})
          ) OR
          (
            UPPER(taxon_concepts.data->'kingdom_name') = 'PLANTAE'
              AND SQUISH_NULL(source_code) IN (#{INVALID_KINGDOM_SOURCE['PLANTAE'].map{|c| "'#{c}'"}.join(',')})
          )
        SQL
     ).
     where(:taxonomies => {:name => Taxonomy::CITES_EU}).
     select(['COUNT(*) AS error_count', "ARRAY_AGG(#{table_name}.id) AS matching_records_ids", 
            'SQUISH_NULL(species_name) AS species_name', 'SQUISH_NULL(source_code) AS source_code']).
     group('SQUISH_NULL(species_name), SQUISH_NULL(source_code)')
  end
end
