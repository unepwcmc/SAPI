# == Schema Information
#
# Table name: trade_annual_report_uploads
#
#  id                 :integer          not null, primary key
#  created_by         :integer
#  updated_by         :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  is_done            :boolean          default(FALSE)
#  number_of_rows     :integer
#  csv_source_file    :text
#  trading_country_id :integer          not null
#  point_of_view      :string(255)      default("E"), not null
#

require 'spec_helper'

describe Trade::AnnualReportUpload, :drops_tables => true do
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
  def importer_file_w_blanks
    Rack::Test::UploadedFile.new(
      File.join(Rails.root, 'spec', 'support', 'annual_report_upload_importer_blanks.csv')
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

  describe :create do
    context "when blank lines in import file" do
      subject{
        create(
          :annual_report_upload,
          :point_of_view => 'I',
          :csv_source_file => importer_file_w_blanks
        )
      }
      specify {
        sandbox_klass = Trade::SandboxTemplate.ar_klass(subject.sandbox.table_name)
        sandbox_klass.count.should == 10
      }
    end
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

  describe :submit do
    before(:each) do
      genus = create_cites_eu_genus(
        :taxon_name => create(:taxon_name, :scientific_name => 'Acipenser')
      )
      species = create_cites_eu_species(
        :taxon_name => create(:taxon_name, :scientific_name => 'baerii'),
        :parent_id => genus.id
      )
      create(:term, :code => 'CAV')
      create(:unit, :code => 'KIL')
      country = create(:geo_entity_type, :name => 'COUNTRY')
      @argentina = create(:geo_entity,
                          :geo_entity_type => country,
                          :name => 'Argentina',
                          :iso_code2 => 'AR'
                         )

      @portugal = create(:geo_entity,
                         :geo_entity_type => country,
                         :name => 'Portugal',
                         :iso_code2 => 'PT'
                        )
    end
    context "when no primary errors" do
      subject { #aru no primary errors
        aru = build(:annual_report_upload, :trading_country_id => @argentina.id, :point_of_view => 'I')
        aru.save(:validate => false)
        sandbox_klass = Trade::SandboxTemplate.ar_klass(aru.sandbox.table_name)
        sandbox_klass.create(
          :species_name => 'Acipenser baerii',
          :appendix => 'II',
          :trading_partner => @portugal.iso_code2,
          :term_code => 'CAV',
          :unit_code => 'KIL',
          :year => '2010',
          :quantity => 1,
          :import_permit => 'XXX'
        )
        create(
          :format_validation_rule,
          :column_names => ['year'],
          :format_re => '^\d{4}$'
        )
        aru
      }
      specify {
        expect{subject.submit}.to change{Trade::Shipment.count}.by(1)
      }
      context "when permit previously reported" do
        before(:each) { create(:permit, :number => 'XXX', :geo_entity => @argentina) }
        specify {
          expect{subject.submit}.not_to change{Trade::Permit.count}
        }
      end
    end
    context "when primary errors present" do
      subject { #aru with primary errors
        aru = build(:annual_report_upload)
        aru.save(:validate => false)
        sandbox_klass = Trade::SandboxTemplate.ar_klass(aru.sandbox.table_name)
        sandbox_klass.create(
          :species_name => 'Acipenser baerii',
          :appendix => 'II',
          :term_code => 'CAV',
          :unit_code => 'KIL',
          :year => '10'
        )
        create(
          :format_validation_rule,
          :column_names => ['year'],
          :format_re => '^\d{4}$'
        )
        aru
      }
      specify {
        expect{subject.submit}.not_to change{Trade::Shipment.count}
      }
    end

  end

end
