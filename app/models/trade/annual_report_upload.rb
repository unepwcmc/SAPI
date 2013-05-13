class Trade::AnnualReportUpload < ActiveRecord::Base
  attr_reader :path, :original_filename, :length
  def save_temp_file(uploaded_file)
    @original_filename = uploaded_file.original_filename
    @length = uploaded_file.tempfile.length
    if ["development", "test"].include?(Rails.env)
      save_in_tmp uploaded_file
    else
      copy_to_db_server uploaded_file
    end
    #Trade::AnnualReportCopyWorker.perform_async(self)
    copy_to_sandbox
  end

  def save_in_tmp uploaded_file
    directory = "tmp/uploads"
    # create the file path
    @path = File.join(directory, @original_filename)
    # write the file
    File.open(@path, "wb") { |f| f.write(uploaded_file.read) }
  end

  def copy_to_db_server uploaded_file
    require 'net/scp'
    directory = '/home/rails/sapi/current/tmp/uploads/'
    @path = File.join(directory, @original_filename)
    destiny = Rails.configuration.database_configuration[Rails.env]["host"]
    Net::SCP.start(destiny, 'rails') do |scp|
      scp.upload! uploaded_file.tempfile.path, @path
    end
  end

  def copy_to_sandbox
    @sandbox = Trade::Sandbox.new(self)
    @sandbox.copy
  end

end
