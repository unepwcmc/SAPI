class Trade::AnnualReportUpload < ActiveRecord::Base
  TMP_DIR = 'tmp/uploads'
  attr_reader :path
  attr_accessible :original_filename, :number_of_rows

  def save_temp_file(uploaded_file)
    @original_filename = uploaded_file.original_filename
    if Rails.env != "production"
      save_in_tmp uploaded_file
    else
      copy_to_db_server uploaded_file
    end
    copy_to_sandbox
  end

  def save_in_tmp uploaded_file
    # create the file path
    @path = File.join(TMP_DIR, @original_filename)
    File.open(@path, "wb") { |f| f.write(uploaded_file.read) }
  end

  def copy_to_db_server uploaded_file
    require 'net/scp'
    @path = File.join('/home/rails/sapi/current', TMP_DIR, @original_filename)
    destiny = Rails.configuration.database_configuration[Rails.env]["host"]
    Net::SCP.start(destiny, 'rails') do |scp|
      scp.upload! uploaded_file.tempfile.path, @path
    end
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
