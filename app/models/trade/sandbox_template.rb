# == Schema Information
#
# Table name: trade_sandbox_template
#
#  id                        :integer          not null, primary key
#  appendix                  :string(255)
#  taxon_name                :string(255)
#  term_code                 :string(255)
#  quantity                  :string(255)
#  unit_code                 :string(255)
#  trading_partner           :string(255)
#  country_of_origin         :string(255)
#  export_permit             :string(255)
#  origin_permit             :string(255)
#  purpose_code              :string(255)
#  source_code               :string(255)
#  year                      :string(255)
#  import_permit             :string(255)
#  reported_taxon_concept_id :integer
#  taxon_concept_id          :integer
#

class Trade::SandboxTemplate < ActiveRecord::Base

  self.table_name = :trade_sandbox_template

  COLUMNS_IN_CSV_ORDER = [
    "appendix", "species_name", "term_code", "quantity", "unit_code",
    "trading_partner", "country_of_origin", "import_permit", "export_permit",
    "origin_permit", "purpose_code", "source_code", "year"
  ]
  CSV_IMPORTER_COLUMNS = COLUMNS_IN_CSV_ORDER
  CSV_EXPORTER_COLUMNS = COLUMNS_IN_CSV_ORDER - ['import_permit']
  IMPORTER_COLUMNS = CSV_IMPORTER_COLUMNS.map{ |c| c == 'species_name' ? 'taxon_name' : c }
  EXPORTER_COLUMNS = CSV_EXPORTER_COLUMNS.map{ |c| c == 'species_name' ? 'taxon_name' : c }

  # Dynamically define AR class for table_name
  # (unless one exists already)
  def self.ar_klass(table_name)
    klass_name = table_name.camelize
    begin
      "Trade::#{klass_name}".constantize
    rescue NameError
      klass = Class.new(ActiveRecord::Base) do
        self.table_name = table_name
        include ActiveModel::ForbiddenAttributesProtection
        attr_accessible :appendix,
          :taxon_name,
          :term_code,
          :quantity,
          :unit_code,
          :trading_partner,
          :country_of_origin,
          :import_permit,
          :export_permit,
          :origin_permit,
          :purpose_code,
          :source_code,
          :year
        belongs_to :taxon_concept

        def sanitize
          self.class.sanitize(self.id)
        end

        def self.sanitize(id = nil)
          update_all(
            'appendix = UPPER(SQUISH_NULL(appendix)),
            year = SQUISH_NULL(year),
            term_code = UPPER(SQUISH_NULL(term_code)),
            unit_code = UPPER(SQUISH_NULL(unit_code)),
            purpose_code = UPPER(SQUISH_NULL(purpose_code)),
            source_code = UPPER(SQUISH_NULL(source_code)),
            quantity = SQUISH_NULL(quantity),
            trading_partner = UPPER(SQUISH_NULL(trading_partner)),
            country_of_origin = UPPER(SQUISH_NULL(country_of_origin)),
            import_permit = UPPER(SQUISH_NULL(import_permit)),
            export_permit = UPPER(SQUISH_NULL(export_permit)),
            origin_permit = UPPER(SQUISH_NULL(origin_permit))
            ',
            id.blank? ? nil : {:id => id}
          )
          # resolve reported & accepted taxon
          connection.execute(
            sanitize_sql_array([
              'SELECT * FROM resolve_taxa_in_sandbox(?, ?)',
              @table_name,
              id
            ])
          )
        end

        def save(attributes = {})
          super(attributes)
          sanitize
        end

        def self.update_batch(updates, sandbox_shipments_ids)
          return unless updates
          where(:id => sandbox_shipments_ids).update_all(updates)
          sanitize
        end

        def self.destroy_batch(sandbox_shipments_ids)
          where(:id => sandbox_shipments_ids).delete_all
        end

      end
      Trade.const_set(klass_name, klass)
    end
  end

  private
  def self.create_table_stmt(target_table_name)
    sql = <<-SQL
      CREATE TABLE #{target_table_name} (PRIMARY KEY(id))
      INHERITS (#{table_name})
    SQL
  end

  def self.create_indexes_stmt(target_table_name)
    sql = <<-SQL
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
    sql = <<-SQL
      CREATE VIEW #{target_table_name}_view AS
      SELECT aru.point_of_view,
      CASE
        WHEN aru.point_of_view = 'E'
        THEN geo_entities.iso_code2
        ELSE trading_partner
      END AS exporter,
      CASE
        WHEN aru.point_of_view = 'E'
        THEN trading_partner
        ELSE geo_entities.iso_code2 
      END AS importer,
      taxon_concepts.full_name AS accepted_taxon_name,
      #{target_table_name}.*
      FROM #{target_table_name}
      JOIN trade_annual_report_uploads aru ON aru.id = #{idx}
      JOIN geo_entities ON geo_entities.id = aru.trading_country_id
      LEFT JOIN taxon_concepts ON taxon_concept_id = taxon_concepts.id
    SQL
  end

  def self.drop_stmt(target_table_name)
    sql = <<-SQL
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
    sanitize_sql_array([sql, csv_file_path])
  end

end
