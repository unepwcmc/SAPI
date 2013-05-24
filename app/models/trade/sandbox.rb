class Trade::Sandbox
  attr_reader :table_name
  def initialize(annual_report_upload)
    @annual_report_upload = annual_report_upload
    @csv_file_path = @annual_report_upload.csv_source_file.current_path
    @table_name = "trade_sandbox_#{@annual_report_upload.id}"
  end

  def copy
    create_target_table
    copy_csv_to_target_table
  end

  def destroy
    Trade::SandboxTemplate.connection.execute(
      Trade::SandboxTemplate.drop_stmt(@table_name)
    )
  end

  def shipments
    Trade::SandboxTemplate.select('*').from(@table_name)
  end

  def submit_permits
    cmd = <<-SQL
      INSERT INTO trade_permits(number, geo_entity_id)
      SELECT DISTINCT origin_permit, geo_entities.id
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
        end}
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
        end}
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
end
