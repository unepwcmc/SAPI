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
    sanitize
  end

  def sanitize(id = nil)
    @ar_klass.update_all(
      'species_name = sanitize_species_name(species_name)',
      id.blank? ? nil : {:id => id}
    )
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
        s && s.update_attributes(shipment) && sanitize(s.id)
      end
    end
  end

  private

  def create_target_table
    unless Trade::SandboxTemplate.connection.table_exists? @table_name
      Thread.new do
        Trade::SandboxTemplate.connection.execute(
          Trade::SandboxTemplate.create_table_stmt(@table_name)
        )
        Trade::SandboxTemplate.connection.execute(
          Trade::SandboxTemplate.create_indexes_stmt(@table_name)
        )
        Trade::SandboxTemplate.connection.execute(
          Trade::SandboxTemplate.create_view_stmt(@table_name, @annual_report_upload.id)
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
