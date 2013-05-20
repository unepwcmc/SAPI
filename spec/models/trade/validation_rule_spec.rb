require 'spec_helper'

describe Trade::ValidationRule do
    let(:annual_report_upload){
      create(
        :annual_report_upload,
        :csv_source_file => Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'annual_report_upload_correct_min.csv'))
      )
    }
    let(:sandbox_table_name){
      annual_report_upload.sandbox.table_name
    }
  describe Trade::PresenceValidationRule do
    describe :matching_records do
      let!(:sandbox_records){
        Trade::SandboxTemplate.connection.execute <<-SQL
          INSERT INTO #{sandbox_table_name}
          (trading_partner_code) VALUES (NULL)
        SQL
      }
      context 'trading_partner_code should not be blank' do
        subject{
          create(
            :presence_validation_rule,
            :column_names => ['trading_partner_code']
          )
        }
        specify{
          subject.matching_records(sandbox_table_name).size.should == 1
        }
      end
    end
  end

  describe Trade::NumericalityValidationRule do
    describe :matching_records do

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
          subject.matching_records(sandbox_table_name).size.should == 1
        }
      end
    end
  end

describe Trade::FormatValidationRule do
    describe :matching_records do

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
          subject.matching_records(sandbox_table_name).size.should == 1
        }
      end
    end
  end

describe Trade::InclusionValidationRule do
    describe :matching_records do
      let!(:france){
        create(
          :geo_entity,
          :geo_entity_type => create(:geo_entity_type, :name => GeoEntityType::COUNTRY),
          :name => 'France',
          :iso_code2 => 'FR'
        )
      }
      let!(:sandbox_records){
        Trade::SandboxTemplate.connection.execute <<-SQL
          INSERT INTO #{sandbox_table_name}
          (trading_partner_code) VALUES ('Neverland')
        SQL
      }
      context 'trading partner code should be a valid iso code' do
        subject{
          create(
            :inclusion_validation_rule,
            :column_names => ['trading_partner_code'],
            :valid_values_view => 'valid_trading_partner_code_view'
          )
        }
        specify{
          subject.matching_records(sandbox_table_name).size.should == 1
        }
      end
    end
  end

end
