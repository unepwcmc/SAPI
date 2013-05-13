class Trade::AnnualReportUpload < ActiveRecord::Base
  TMP_DIR = 'tmp/uploads'
  attr_reader :path
  attr_accessible :original_filename, :number_of_rows

  def save_temp_file(uploaded_file)
    @original_filename = uploaded_file.original_filename
    @path = File.join(TMP_DIR, @original_filename)
    File.open(@path, "wb") { |f| f.write(uploaded_file.read) }
    copy_to_sandbox
  end

  def copy_to_sandbox
    sandbox.copy
    update_attributes({:original_filename => @original_filename, :number_of_rows => sandbox_shipments.size})
  end

  # object that represents the particular sandbox table linked to this annual
  # report upload
  def sandbox
    return nil if is_done
    @sandbox ||= Trade::Sandbox.new(self)
  end

  def sandbox_shipments
    return [] if is_done
    Trade::SandboxTemplate.select('*').from(sandbox.table_name)
  end

end
