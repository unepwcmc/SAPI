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
  let(:sandbox_klass){
    Trade::SandboxTemplate.ar_klass(annual_report_upload.sandbox.table_name)
  }

  describe Trade::PresenceValidationRule do
    describe :validation_errors do
      before(:each) do
        sandbox_klass.create(:trading_partner => nil)
      end
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
      before(:each) do
        sandbox_klass.create(:quantity => 'www')
      end
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
      before(:each) do
        sandbox_klass.create(:year => '33333')
      end
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
      context 'species name may have extra whitespace between name segments' do
        before(:each) do
          genus = create_cites_eu_genus(
            :taxon_name => create(:taxon_name, :scientific_name => 'Acipenser')
          )
          create_cites_eu_species(
            :taxon_name => create(:taxon_name, :scientific_name => 'baerii'),
            :parent => genus
          )
        end
        subject{
          create(
            :inclusion_validation_rule,
            :column_names => ['species_name'],
            :valid_values_view => 'valid_species_name_view'
          )
        }
        specify{
          subject.validation_errors(annual_report_upload).should be_empty
        }
      end
      context 'trading partner should be a valid iso code' do
        before(:each) do
          sandbox_klass.create(:trading_partner => 'Neverland')
          sandbox_klass.create(:trading_partner => '')
          sandbox_klass.create(:trading_partner => nil)
        end
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
