class Trade::AnnualReportUpload < ActiveRecord::Base
  attr_accessible :number_of_rows, :csv_source_file
  mount_uploader :csv_source_file, Trade::CsvSourceFileUploader

  def copy_to_db_server
    return true unless Rails.env.production?
    require 'net/scp'
    remote_path = File.join('/home/rails/sapi/current', csv_source_file.current_path)
    destiny = Rails.configuration.database_configuration[Rails.env]["host"]
    Net::SCP.start(destiny, 'rails') do |scp|
      scp.upload! csv_source_file.current_path, remote_path
    end
  end

  def copy_to_sandbox
    sandbox.copy
    update_attribute(:number_of_rows, sandbox_shipments.size)
  end

  # object that represents the particular sandbox table linked to this annual
  # report upload
  def sandbox
    return nil if is_done
    @sandbox ||= Trade::Sandbox.new(self)
  end

  def sandbox_shipments
    return [] if is_done
    sandbox.shipments
  end

end
