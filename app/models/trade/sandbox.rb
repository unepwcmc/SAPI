require 'csv_copy'
class Trade::Sandbox
	attr_reader :table_name
	def initialize(annual_report_upload)
		@id = annual_report_upload.id
		@csv_file_path = annual_report_upload.path
		create_table
	end

	def create_table
		@table_name = "trade_sandbox_#{@id}"
		unless ActiveRecord::Base.connection.table_exists? @table_name
			ActiveRecord::Base.connection.execute("CREATE TABLE #{@table_name} () INHERITS (trade_sandbox_template)")
		end
	end

	def copy
		CsvCopy::copy_data(@csv_file_path, @table_name, Trade::SandboxTemplate.column_names)
	end

end
