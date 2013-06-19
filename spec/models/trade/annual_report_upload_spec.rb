# == Schema Information
#
# Table name: trade_annual_report_uploads
#
#  id                 :integer          not null, primary key
#  created_by         :integer
#  updated_by         :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  original_filename  :string(255)
#  number_of_rows     :integer
#  is_done            :boolean          default(FALSE)
#  csv_source_file    :text
#  trading_country_id :integer          not null
#  point_of_view      :string(255)      default("E"), not null
#

require 'spec_helper'

describe Trade::AnnualReportUpload do
  def exporter_file
    Rack::Test::UploadedFile.new(
      File.join(Rails.root, 'spec', 'support', 'annual_report_upload_exporter.csv')
    )
  end
  def importer_file
    Rack::Test::UploadedFile.new(
      File.join(Rails.root, 'spec', 'support', 'annual_report_upload_importer.csv')
    )
  end
  def invalid_file
    Rack::Test::UploadedFile.new(
      File.join(Rails.root, 'spec', 'support', 'annual_report_upload_invalid.csv')
    )
  end
  describe :valid? do
    context "when uploaded file as exporter with exporter column headers" do
      subject{
        build(
          :annual_report_upload,
          :point_of_view => 'E',
          :csv_source_file => exporter_file
        )
      }
      specify {subject.should be_valid}
    end
    context "when uploaded file as importer with exporter column headers" do
      subject{
        build(
          :annual_report_upload,
          :point_of_view => 'I',
          :csv_source_file => exporter_file
        )
      }
      specify {subject.should_not be_valid}
    end
    context "when uploaded file as importer with importer column headers" do
      subject{
        build(
          :annual_report_upload,
          :point_of_view => 'I',
          :csv_source_file => importer_file
        )
      }
      specify {subject.should be_valid}
    end
     context "when uploaded file as exporter with importer column headers" do
      subject{
        build(
          :annual_report_upload,
          :point_of_view => 'E',
          :csv_source_file => importer_file
        )
      }
      specify {subject.should_not be_valid}
    end
  end

  describe :validation_errors do
    let!(:format_validation_rule){
      create(
        :format_validation_rule,
        :column_names => ['year'],
        :format_re => '^\d{4}$'
      )
    }
      subject{
        create(
          :annual_report_upload,
          :point_of_view => 'I',
          :csv_source_file => importer_file
        )
      }
      specify{ subject.validation_errors.should be_empty}
  end

  describe :destroy do
      subject{
        create(
          :annual_report_upload,
          :point_of_view => 'I',
          :csv_source_file => importer_file
        )
      }
      specify{
          subject.sandbox.should_receive(:destroy)
          subject.destroy
      }
  end
end
