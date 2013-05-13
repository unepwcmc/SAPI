class Trade::AnnualReportUpload < ActiveRecord::Base
  attr_reader :path, :original_filename, :length

  # TODO store that
  def number_of_rows
    sandbox_shipments.size
  end

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
    sandbox.copy
  end

  # object that represents the particular sandbox table linked to this annual
  # report upload
  def sandbox
    # TODO return nil if sandbox submitted
    @sandbox ||= Trade::Sandbox.new(self)
  end

  def sandbox_shipments
    # TODO return nil if sandbox submitted
    Trade::SandboxTemplate.select('*').from(sandbox.table_name)
  end

end
