require 'csv_copy'
class Trade::Sandbox
	def initialize(annual_report_upload)
		@id = annual_report_upload.id
		@csv_file_path = annual_report_upload.path
		create_table
	end

	def create_table
		@table_name = "sandbox_#{@id}"
		ActiveRecord::Base.connection.execute("CREATE TABLE #{@table_name} () INHERITS (sandbox_template)")
	end

	def copy
		CsvCopy::copy_data(@csv_file_path, @table_name, Trade::SandboxTemplate.column_names)
	end

end
