# == Schema Information
#
# Table name: trade_validation_rules
#
#  id                :integer          not null, primary key
#  valid_values_view :string(255)
#  type              :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  format_re         :string(255)
#  run_order         :integer          not null
#  column_names      :string(255)
#

require 'spec_helper'

describe Trade::ValidationRule do
  let(:annual_report_upload){
    create(
      :annual_report_upload,
      :point_of_view => 'E',
      :csv_source_file => Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'annual_report_upload_exporter.csv'))
    )
  }
  let(:sandbox_table_name){
    annual_report_upload.sandbox.table_name
  }

  describe Trade::PresenceValidationRule do
    describe :validation_errors do
      let!(:sandbox_records){
        Trade::SandboxTemplate.connection.execute <<-SQL
          INSERT INTO #{sandbox_table_name}
          (trading_partner) VALUES (NULL)
        SQL
      }
      context 'trading_partner should not be blank' do
        subject{
          create(
            :presence_validation_rule,
            :column_names => ['trading_partner']
          )
        }
        specify{
          subject.validation_errors(annual_report_upload).size.should == 1
        }
      end
    end
  end

  describe Trade::NumericalityValidationRule do
    describe :validation_errors do

      let!(:sandbox_records){
        Trade::SandboxTemplate.connection.execute <<-SQL
          INSERT INTO #{sandbox_table_name}
          (quantity) VALUES ('www')
        SQL
      }
      context 'quantity should be a number' do
        subject{
          create(
            :numericality_validation_rule,
            :column_names => ['quantity']
          )
        }
        specify{
          subject.validation_errors(annual_report_upload).size.should == 1
        }
      end
    end
  end

describe Trade::FormatValidationRule do
    describe :validation_errors do

      let!(:sandbox_records){
        Trade::SandboxTemplate.connection.execute <<-SQL
          INSERT INTO #{sandbox_table_name}
          (year) VALUES ('33333')
        SQL
      }
      context 'year should be a 4 digit value' do
        subject{
          create(
            :format_validation_rule,
            :column_names => ['year'],
            :format_re => '^\d{4}$'
          )
        }
        specify{
          subject.validation_errors(annual_report_upload).size.should == 1
        }
      end
    end
  end

describe Trade::InclusionValidationRule do
    describe :validation_errors do
      context 'trading partner should be a valid iso code' do
        let(:country){
          create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
        }
        let!(:france){
          create(
            :geo_entity,
            :geo_entity_type => country,
            :name => 'France',
            :iso_code2 => 'FR'
          )
        }
        let!(:sandbox_records){
          Trade::SandboxTemplate.connection.execute <<-SQL
            INSERT INTO #{sandbox_table_name}
            (trading_partner) VALUES ('Neverland')
          SQL
          Trade::SandboxTemplate.connection.execute <<-SQL
            INSERT INTO #{sandbox_table_name}
            (trading_partner) VALUES ('')
          SQL
          Trade::SandboxTemplate.connection.execute <<-SQL
            INSERT INTO #{sandbox_table_name}
            (trading_partner) VALUES (NULL)
          SQL
        }
        subject{
          create(
            :inclusion_validation_rule,
            :column_names => ['trading_partner'],
            :valid_values_view => 'valid_trading_partner_view'
          )
        }
        specify{
          subject.validation_errors(annual_report_upload).size.should == 1
        }
      end
    end
  end

end
