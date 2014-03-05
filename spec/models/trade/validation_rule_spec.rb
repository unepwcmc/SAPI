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
#  is_primary        :boolean          default(TRUE), not null
#  scope             :hstore
#

require 'spec_helper'

describe Trade::ValidationRule, :drops_tables => true do
  let(:annual_report_upload){
    annual_report = build(
      :annual_report_upload,
      :point_of_view => 'E'
    )
    annual_report.save(:validate => false)
    annual_report
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
        specify{
          ve = subject.validation_errors(annual_report_upload).first
          ve.error_selector.should == {'trading_partner' => nil}
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
            :column_names => ['quantity'],
            :is_strict => true
          )
        }
        specify{
          subject.validation_errors(annual_report_upload).size.should == 1
        }
        specify{
          ve = subject.validation_errors(annual_report_upload).first
          ve.error_selector.should == {'quantity' => ['www']}
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
          create_year_format_validation
        }
        specify{
          subject.validation_errors(annual_report_upload).size.should == 1
        }
        specify{
          ve = subject.validation_errors(annual_report_upload).first
          ve.error_selector.should == {'year' => ['33333']}
        }
      end
    end
  end
end
