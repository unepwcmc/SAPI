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
