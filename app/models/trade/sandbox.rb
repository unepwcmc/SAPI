class Trade::Sandbox
  attr_reader :table_name
  def initialize(annual_report_upload)
    @annual_report_upload = annual_report_upload
    @csv_file_path = @annual_report_upload.csv_source_file.current_path
    @table_name = "trade_sandbox_#{@annual_report_upload.id}"
    @ar_klass = Trade::SandboxTemplate.ar_klass(@table_name)
  end

  def copy
    create_target_table
    copy_csv_to_target_table
    duplicate_columns_in_target_table
  end

  def destroy
    Trade::SandboxTemplate.connection.execute(
      Trade::SandboxTemplate.drop_stmt(@table_name)
    )
  end

  def shipments
    @ar_klass.order(:id).all
  end

  def shipments=(new_shipments)
    #TODO handle errors
    new_shipments.each do |shipment|
      s = @ar_klass.find_by_id(shipment.delete('id'))
      if shipment.delete('_destroyed')
        s && s.delete
      else
        s && s.update_attributes(shipment)
      end
    end
  end

  def submit_permits
    cmd = <<-SQL
      INSERT INTO trade_permits(number, geo_entity_id, created_at, updated_at)
      SELECT DISTINCT origin_permit, geo_entities.id, current_date, current_date
      FROM #{@table_name}
      INNER JOIN geo_entities ON geo_entities.iso_code2 = country_of_origin
      WHERE origin_permit IS NOT NULL AND country_of_origin IS NOT NULL
        AND NOT EXISTS (
          SELECT id FROM trade_permits
          WHERE geo_entity_id = geo_entities.id
            AND number = origin_permit
        )
      UNION
      SELECT DISTINCT export_permit,
      #{if @annual_report_upload.point_of_view == 'E'
        then @annual_report_upload.trading_country_id
        else "geo_entities.id"
        end}, current_date, current_date
      FROM #{@table_name}
      INNER JOIN geo_entities ON geo_entities.iso_code2 = trading_partner
      WHERE export_permit IS NOT NULL
        AND NOT EXISTS (
          SELECT id from trade_permits
          WHERE geo_entity_id = #{ if @annual_report_upload.point_of_view == "E"
            then @annual_report_upload.trading_country_id
            else "geo_entities.id" end } AND number = export_permit
        )
      UNION
      SELECT DISTINCT import_permit,
      #{if @annual_report_upload.point_of_view == 'E'
        then "geo_entities.id"
        else @annual_report_upload.trading_country_id
        end}, current_date, current_date
      FROM #{@table_name}
      INNER JOIN geo_entities ON geo_entities.iso_code2 = trading_partner
      WHERE import_permit IS NOT NULL
        AND NOT EXISTS (
          SELECT id from trade_permits
          WHERE geo_entity_id = #{ if @annual_report_upload.point_of_view == "E"
            then 'geo_entities.id'
            else @annual_report_upload.trading_country_id end}
            AND number = import_permit
        )
    SQL
    ActiveRecord::Base.connection.execute(cmd)
  end

  def submit_shipments
    cmd = <<-SQL
      INSERT INTO trade_shipments (source_id, unit_id, purpose_id,
        term_id, quantity, reported_appendix, appendix,
        trade_annual_report_upload_id, exporter_id, importer_id,
        country_of_origin_id, country_of_origin_permit_id,
        import_permit_id, reported_by_exporter, taxon_concept_id,
        reported_species_name, year, created_at, updated_at)
      SELECT sources.id, units.id, purposes.id,
        terms.id, #{@table_name}.quantity::NUMERIC, #{@table_name}.reported_appendix,
        #{@table_name}.appendix, #{@annual_report_upload.id}, exporters.id, importers.id,
        origins.id, origin_permits.id, import_permits.id,
        '#{ @annual_report_upload.point_of_view == "E" ? 't' : 'f'}'::BOOLEAN,
        taxon_concepts.id, #{@table_name}.species_name, #{@table_name}.year::INTEGER,
        current_date, current_date
      FROM #{@table_name}
      LEFT JOIN trade_codes AS sources ON #{@table_name}.source_code = sources.code
        AND sources.type = 'Source'
      LEFT JOIN trade_codes AS units ON #{@table_name}.unit_code = units.code
        AND units.type = 'Unit'
      LEFT JOIN trade_codes AS purposes ON #{@table_name}.purpose_code = purposes.code
        AND purposes.type = 'Purpose'
      LEFT JOIN trade_codes AS terms ON #{@table_name}.term_code = terms.code
        AND terms.type = 'Term'
      LEFT JOIN geo_entities AS exporters ON
        #{if @annual_report_upload.point_of_view == 'E'
            then "exporters.id = #{@annual_report_upload.trading_country_id}"
            else "exporters.iso_code2 = #{@table_name+'.trading_partner'}" end}
      LEFT JOIN geo_entities AS importers ON
        #{if @annual_report_upload.point_of_view == 'E'
            then "importers.iso_code2 = #{@table_name+'.trading_partner'}"
            else "importers.id = #{@annual_report_upload.trading_country_id}" end}
      LEFT JOIN geo_entities AS origins ON origins.iso_code2 = #{@table_name}.country_of_origin
      LEFT JOIN trade_permits AS origin_permits ON origin_permits.number = #{@table_name}.origin_permit
      LEFT JOIN trade_permits AS import_permits ON import_permits.number = #{@table_name}.import_permit
      INNER JOIN taxon_concepts_mview AS taxon_concepts ON taxon_concepts.full_name = #{@table_name}.species_name
    SQL
    ActiveRecord::Base.connection.execute(cmd)
  end

  private

  def create_target_table
    unless Trade::SandboxTemplate.connection.table_exists? @table_name
      Thread.new do
        Trade::SandboxTemplate.connection.execute(
          Trade::SandboxTemplate.create_stmt(@table_name)
        )
      end.join
    end
  end

  def copy_csv_to_target_table
    require 'psql_command'
    columns_in_csv_order = if (@annual_report_upload.point_of_view == 'E')
      Trade::SandboxTemplate::EXPORTER_COLUMNS
    else
      Trade::SandboxTemplate::IMPORTER_COLUMNS
    end
    cmd = Trade::SandboxTemplate.copy_stmt(@table_name, @csv_file_path, columns_in_csv_order)
    PsqlCommand.new(cmd).execute
  end

  def duplicate_columns_in_target_table
    require 'psql_command'
    cmd = Trade::SandboxTemplate.duplicate_column_stmt(@table_name,
                                                        "appendix",
                                                        "reported_appendix")
    Thread.new do
      Trade::SandboxTemplate.connection.execute(cmd)
    end
  end
end
