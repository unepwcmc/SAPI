require 'csv_copy'
class Trade::Sandbox
	#Cinclude CsvCopy
	def initialize(csv_file_path)
		@csv_file_path = csv_file_path
		create_table
	end

	CSV_COLUMNS = %w(
		Appendix_no  Taxon_check Term_code Quantity  Unit_code Trading_partner_code  Origin_country_code Export_permit Origin_permit Purpose_code  Source_code Year
	)

	MAPPING = Hash[CSV_COLUMNS.map{ |c| [c, "#{c} TEXT"] }]

	def db_columns
		MAPPING.values
	end

	def create_table
		@table_name = "sandbox_#{Time.now.hash}"
		ActiveRecord::Base.connection.execute("CREATE TABLE #{@table_name} (#{db_columns.join(', ')})")
	end

	def copy
		CsvCopy::copy_data(@csv_file_path, @table_name, CSV_COLUMNS)
	end

end