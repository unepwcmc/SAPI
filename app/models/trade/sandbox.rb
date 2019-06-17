class Trade::Sandbox
  attr_reader :table_name, :ar_klass, :moved_rows_cnt
  def initialize(annual_report_upload)
    @annual_report_upload = annual_report_upload
    @csv_file_path = @annual_report_upload.csv_source_file.current_path
    @table_name = "trade_sandbox_#{@annual_report_upload.id}"
    @ar_klass = Trade::SandboxTemplate.ar_klass(@table_name)
    @moved_rows_cnt = -1
  end

  def copy
    create_target_table
    copy_csv_to_target_table
    @ar_klass.sanitize
  end

  def copy_from_sandbox_to_shipments(submitter)
    success = true
    Trade::Shipment.transaction do
      pg_result = Trade::SandboxTemplate.connection.execute(
        Trade::SandboxTemplate.send(:sanitize_sql_array, [
          'SELECT * FROM copy_transactions_from_sandbox_to_shipments(?, ?, ?)',
          @annual_report_upload.id,
          'Sapi',
          submitter.id
        ])
      )
      @moved_rows_cnt = pg_result.first['copy_transactions_from_sandbox_to_shipments'].to_i
      if @moved_rows_cnt < 0
        # if -1 returned, not all rows have been moved
        @annual_report_upload.errors[:base] << "Submit failed, could not save all rows."
        success = false
        raise ActiveRecord::Rollback
      end
    end
    success
  end

  def check_for_duplicates_in_shipments
    Trade::Shipment.transaction do
      pg_result = Trade::SandboxTemplate.connection.execute(
        Trade::SandboxTemplate.send(:sanitize_sql_array, [
          'SELECT * FROM check_for_duplicates_in_shipments(?)',
          @annual_report_upload.id,
        ])
      )
      duplicates = pg_result.values.first.first.delete('{}')
      return duplicates
    end
  end

  def destroy
    Trade::SandboxTemplate.connection.execute(
      Trade::SandboxTemplate.drop_stmt(@table_name)
    )
  end

  def shipments
    @ar_klass.order(:id).to_a
  end

  def shipments=(new_shipments)
    # TODO: handle errors
    new_shipments.each do |shipment|
      s = @ar_klass.find_by_id(shipment.delete('id'))
      s.delete_or_update_attributes(shipment)
    end
  end

  private

  def create_target_table
    unless Trade::SandboxTemplate.connection.table_exists? @table_name
      Thread.new do
        begin
          Trade::SandboxTemplate.connection.execute(
            Trade::SandboxTemplate.create_table_stmt(@table_name)
          )
        ensure
          ActiveRecord::Base.clear_active_connections!
        end
        begin
          Trade::SandboxTemplate.connection.execute(
            Trade::SandboxTemplate.create_indexes_stmt(@table_name)
          )
        ensure
          ActiveRecord::Base.clear_active_connections!
        end
        begin
          Trade::SandboxTemplate.connection.execute(
            Trade::SandboxTemplate.create_view_stmt(@table_name, @annual_report_upload.id)
          )
        ensure
          ActiveRecord::Base.clear_active_connections!
        end
      end.join
    end
  end

  def copy_csv_to_target_table
    require 'psql_command'
    columns_in_csv_order =
      if (@annual_report_upload.point_of_view == 'E')
        Trade::SandboxTemplate::EXPORTER_COLUMNS
      else
        Trade::SandboxTemplate::IMPORTER_COLUMNS
      end
    cmd = Trade::SandboxTemplate.copy_stmt(@table_name, @csv_file_path, columns_in_csv_order)
    PsqlCommand.new(cmd).execute
  end

end
