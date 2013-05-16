class Trade::Sandbox
  def initialize(annual_report_upload)
    @annual_report_upload = annual_report_upload
    @csv_file_path = @annual_report_upload.csv_source_file.current_path
    @table_name = "trade_sandbox_#{@annual_report_upload.id}"
  end

  def copy
    create_target_table
    copy_csv_to_target_table
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
    cmd = Trade::SandboxTemplate.copy_stmt(@table_name, @csv_file_path)
    PsqlCommand.new(cmd).execute
  end

end
