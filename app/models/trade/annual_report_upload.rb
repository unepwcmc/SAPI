class Trade::AnnualReportUpload
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  include ActiveModel::Serialization

  def initialize(uploaded_file = {})
    @original_filename = uploaded_file.original_filename
    @length = uploaded_file.tempfile.length
    directory = "tmp/data"
    # create the file path
    @path = File.join(directory, @original_filename)
    # write the file
    File.open(@path, "wb") { |f| f.write(uploaded_file.read) }
    Trade::AnnualReportCopyWorker.perform_async(self)
  end

  def valid_columns
    %w(Appendix_no  Taxon_check Term_code Quantity  Unit_code Trading_partner_code  Origin_country_code Export_permit Origin_permit Purpose_code  Source_code Year)
  end

  def copy_to_sandbox
    @table = "sandbox_#{Time.now}"
    CsvCopy::copy_data(@path, @table, )
  end

  def persisted?
    false
  end

end
