require 'csv_copy'
class Trade::Sandbox
	def initialize(csv_file_path)
		@csv_file_path = csv_file_path
		create_table
	end

	def create_table
		@table_name = "sandbox_#{Time.now.hash}"
		ActiveRecord::Base.connection.execute("CREATE TABLE #{@table_name} () INHERITS sandbox_template")
	end

	def copy
		CsvCopy::copy_data(@csv_file_path, @table_name, column_names)
	end

end