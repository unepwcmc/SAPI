class Trade::AnnualReportUpload < ActiveRecord::Base
  attr_reader :path, :original_filename, :length
  def save_temp_file(uploaded_file)
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
    @sandbox = Trade::Sandbox.new(self)
    @sandbox.copy
  end

end
