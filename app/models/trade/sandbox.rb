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
    db_conf = Rails.configuration.database_configuration[Rails.env]
    cmd = Trade::SandboxTemplate.copy_stmt(@table_name, @csv_file_path)
    system("export PGPASSWORD=#{db_conf["password"]} && echo \"#{cmd.split("\n").join(' ')}\" | psql -h #{db_conf["host"] || "localhost"} -p #{db_conf["port"] || 5432} -U#{db_conf["username"]} #{db_conf["database"]}")
  end

end
