class Trade::AnnualReportUpload
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  include ActiveModel::Serialization

  def initialize(uploaded_file = {})
    @original_filename = uploaded_file.original_filename
    @length = uploaded_file.tempfile.length
    directory = "tmp/uploads"
    # create the file path
    @path = File.join(directory, @original_filename)
    # write the file
    File.open(@path, "wb") { |f| f.write(uploaded_file.read) }
    #Trade::AnnualReportCopyWorker.perform_async(self)
    copy_to_sandbox
  end

  def copy_to_sandbox
    @sandbox = Trade::Sandbox.new_upload(@path)
    @sandbox.copy
  end

  def persisted?
    false
  end

end
