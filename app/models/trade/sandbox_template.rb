# == Schema Information
#
# Table name: trade_sandbox_template
#
#  id                        :integer          not null, primary key
#  appendix                  :string(255)
#  country_of_origin         :string(255)
#  epix_created_at           :datetime
#  epix_updated_at           :datetime
#  export_permit             :text
#  import_permit             :text
#  origin_permit             :text
#  purpose_code              :string(255)
#  quantity                  :string(255)
#  source_code               :string(255)
#  taxon_name                :string(255)
#  term_code                 :string(255)
#  trading_partner           :string(255)
#  unit_code                 :string(255)
#  year                      :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#  created_by_id             :integer
#  epix_created_by_id        :integer
#  epix_updated_by_id        :integer
#  reported_taxon_concept_id :integer
#  taxon_concept_id          :integer
#  updated_by_id             :integer
#

class Trade::SandboxTemplate < ApplicationRecord
  self.table_name = :trade_sandbox_template

  has_paper_trail

  COLUMNS_IN_CSV_ORDER = [
    'appendix', 'species_name', 'term_code', 'quantity', 'unit_code',
    'trading_partner', 'country_of_origin', 'import_permit', 'export_permit',
    'origin_permit', 'purpose_code', 'source_code', 'year'
  ]

  CSV_IMPORTER_COLUMNS = COLUMNS_IN_CSV_ORDER
  CSV_EXPORTER_COLUMNS = COLUMNS_IN_CSV_ORDER - [ 'import_permit' ]
  IMPORTER_COLUMNS = CSV_IMPORTER_COLUMNS.map { |c| c == 'species_name' ? 'taxon_name' : c }
  EXPORTER_COLUMNS = CSV_EXPORTER_COLUMNS.map { |c| c == 'species_name' ? 'taxon_name' : c }

  # Dynamically define Annual Report class for table_name
  # (unless one exists already)
  def self.ar_klass(table_name)
    klass_name = table_name.camelize

    begin
      "Trade::#{klass_name}".constantize
    rescue NameError
      klass =
        Class.new(ApplicationRecord) do
          self.table_name = table_name

          has_paper_trail

          include ActiveModel::ForbiddenAttributesProtection
          # Too dynamic, hard to trace where using it.
          # attr_accessible :appendix,
          #   :taxon_name,
          #   :term_code,
          #   :quantity,
          #   :unit_code,
          #   :trading_partner,
          #   :country_of_origin,
          #   :import_permit,
          #   :export_permit,
          #   :origin_permit,
          #   :purpose_code,
          #   :source_code,
          #   :year
          belongs_to :taxon_concept, optional: true
          belongs_to :reported_taxon_concept, class_name: 'TaxonConcept', optional: true

          [
            :appendix,
            :term_code,
            :unit_code,
            :purpose_code,
            :source_code,
            :trading_partner,
            :country_of_origin,
            :import_permit,
            :export_permit,
            :origin_permit
          ].each do |attr_name|
            normalizes(
              attr_name,
              with: ->(value) do
                value&.strip&.presence&.upcase
              end
            )
          end

          normalizes(
            :year,
            with: ->(value) do
              value&.strip&.presence&.to_i
            end
          )

          normalizes(
            :quantity,
            with: ->(value) do
              value&.strip&.presence
            end
          )

          after_save :sanitize

          after_destroy do
            # Bump timestamp to ensure errors refreshed
            self.class.update_all(updated_at: Time.now) # rubocop:disable Rails/SkipsModelValidations
          end

          def sanitize
            self.class.where(id: id).sanitize(id)
          end

          def self.sanitize(id = nil)
            update_all(
              <<-SQL.squish
                appendix = UPPER(SQUISH_NULL(TRIM(appendix))),
                year = SQUISH_NULL(TRIM(year)),
                term_code = UPPER(SQUISH_NULL(TRIM(term_code))),
                unit_code = UPPER(SQUISH_NULL(TRIM(unit_code))),
                purpose_code = UPPER(SQUISH_NULL(TRIM(purpose_code))),
                source_code = UPPER(SQUISH_NULL(TRIM(source_code))),
                quantity = SQUISH_NULL(TRIM(quantity)),
                trading_partner = UPPER(SQUISH_NULL(TRIM(trading_partner))),
                country_of_origin = UPPER(SQUISH_NULL(TRIM(country_of_origin))),
                import_permit = UPPER(SQUISH_NULL(TRIM(import_permit))),
                export_permit = UPPER(SQUISH_NULL(TRIM(export_permit))),
                origin_permit = UPPER(SQUISH_NULL(TRIM(origin_permit)))
              SQL
            )

            # resolve reported & accepted taxon
            connection.execute(
              sanitize_sql_array(
                [
                  'SELECT * FROM resolve_taxa_in_sandbox(?, ?)',
                  @table_name,
                  id
                ]
              )
            )
          end

          def self.records_for_batch_operation(validation_error, annual_report_upload)
            vr = validation_error.validation_rule

            joins(
              <<-SQL.squish
              JOIN (
                #{vr.matching_records_for_aru_and_error(annual_report_upload, validation_error).to_sql}
              ) matching_records on #{table_name}.id = matching_records.id
              SQL
            )
          end

          def self.update_batch(updates, validation_error, annual_report_upload)
            return unless updates

            updates[:updated_at] = Time.now

            records_for_batch_operation(
              validation_error, annual_report_upload
            ).update_all(updates.to_h)

            sanitize
          end

          def self.destroy_batch(validation_error, annual_report_upload)
            records_for_batch_operation(
              validation_error, annual_report_upload
            ).each(&:delete)

            update_all(updated_at: Time.now) # bump timestamp to ensure errors refreshed
          end
        end

      Trade.const_set(klass_name, klass)
    end
  end

private

  def self.create_table_stmt(target_table_name)
    <<-SQL.squish
      CREATE TABLE #{target_table_name} (PRIMARY KEY(id))
      INHERITS (#{table_name})
    SQL
  end

  def self.create_indexes_stmt(target_table_name)
    <<-SQL.squish
      CREATE INDEX ON #{target_table_name} (trading_partner);
      CREATE INDEX ON #{target_table_name} (term_code);
      CREATE INDEX ON #{target_table_name} (taxon_name);
      CREATE INDEX ON #{target_table_name} (taxon_concept_id);
      CREATE INDEX ON #{target_table_name} (appendix);
      CREATE INDEX ON #{target_table_name} (quantity);
      CREATE INDEX ON #{target_table_name} (source_code);
      CREATE INDEX ON #{target_table_name} (purpose_code);
      CREATE INDEX ON #{target_table_name} (unit_code);
      CREATE INDEX ON #{target_table_name} (country_of_origin);
    SQL
  end

  def self.create_view_stmt(target_table_name, idx)
    sanitize_sql_array(
      [
        'SELECT * FROM create_trade_sandbox_view(?, ?)',
        target_table_name,
        idx
      ]
    )
  end

  def self.drop_stmt(target_table_name)
    <<-SQL.squish
      DROP TABLE IF EXISTS #{target_table_name} CASCADE
    SQL
  end

  def self.copy_stmt(target_table_name, csv_file_path, columns_in_csv_order)
    sql = <<-PSQL
      \\COPY #{target_table_name} (#{columns_in_csv_order.join(', ')})
      FROM ?
      WITH DELIMITER ','
      ENCODING 'utf-8'
      CSV HEADER;
    PSQL

    sanitize_sql_array([ sql, csv_file_path ])
  end
end
