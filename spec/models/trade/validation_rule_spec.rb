# == Schema Information
#
# Table name: trade_validation_rules
#
#  id                :integer          not null, primary key
#  column_names      :string(255)      is an Array
#  format_re         :string(255)
#  is_primary        :boolean          default(TRUE), not null
#  is_strict         :boolean          default(FALSE), not null
#  run_order         :integer          not null
#  scope             :hstore
#  type              :string(255)      not null
#  valid_values_view :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'spec_helper'

describe Trade::ValidationRule, drops_tables: true do
  let(:annual_report_upload) do
    annual_report = build(
      :annual_report_upload,
      point_of_view: 'E'
    )
    annual_report.save(validate: false)
    annual_report
  end
  let(:sandbox_klass) do
    Trade::SandboxTemplate.ar_klass(annual_report_upload.sandbox.table_name)
  end

  describe :matching_records_for_aru_and_error do
    let(:validation_rule) do
      create_taxon_name_presence_validation
    end
    before(:each) do
      @shipment1 = sandbox_klass.create(
        taxon_name: 'Canis lupus'
      )
      @shipment2 = sandbox_klass.create(
        taxon_name: nil
      )
      @validation_error = create(
        :validation_error,
        annual_report_upload_id: annual_report_upload.id,
        validation_rule_id: validation_rule.id,
        matching_criteria: {},
        is_ignored: false,
        is_primary: true,
        error_message: 'taxon_name cannot be blank',
        error_count: 1
      )
      validation_rule.refresh_errors_if_needed(annual_report_upload)
    end
    specify do
      expect(
        validation_rule.matching_records_for_aru_and_error(
          annual_report_upload,
          @validation_error
        )
      ).to eq([ @shipment2 ])
    end
  end

  describe :refresh_errors_if_needed do
    let(:validation_rule) do
      create_taxon_name_presence_validation
    end
    before(:each) do
      @shipment1 = sandbox_klass.create(
        taxon_name: 'Canis lupus'
      )
      @shipment2 = sandbox_klass.create(
        taxon_name: ''
      )
      @shipment3 = sandbox_klass.create(
        taxon_name: nil
      )
      @validation_error = create(
        :validation_error,
        annual_report_upload_id: annual_report_upload.id,
        validation_rule_id: validation_rule.id,
        matching_criteria: {},
        is_ignored: false,
        is_primary: true,
        error_message: 'taxon_name cannot be blank',
        error_count: 2
      )
      validation_rule.refresh_errors_if_needed(annual_report_upload)
    end

    context 'when no updates' do
      specify do
        expect do
          validation_rule.refresh_errors_if_needed(annual_report_upload)
        end.not_to change { Trade::ValidationError.count }
      end
    end

    context 'when updates and error fixed for all records' do
      specify 'error record is destroyed' do
        travel_to(Time.now + 1) do
          @shipment2.update(taxon_name: 'Canis lupus')
          @shipment3.update(taxon_name: 'Canis lupus')
          expect do
            validation_rule.refresh_errors_if_needed(annual_report_upload)
          end.to change { Trade::ValidationError.count }.by(-1)
        end
      end
    end

    context 'when updates and error fixed for some records' do
      specify 'error record is updated to reflect new error_count' do
        travel_to(Time.now + 1) do
          @shipment2.update(taxon_name: 'Canis lupus')
          expect do
            validation_rule.refresh_errors_if_needed(annual_report_upload)
          end.to change { @validation_error.reload.error_count }.by(-1)
        end
      end
    end
  end

  describe Trade::PresenceValidationRule do
    describe :validation_errors_for_aru do
      before(:each) do
        sandbox_klass.create(trading_partner: nil)
      end
      context 'trading_partner should not be blank' do
        subject do
          create(
            :presence_validation_rule,
            column_names: [ 'trading_partner' ]
          )
        end
        specify do
          subject.refresh_errors_if_needed(annual_report_upload)
          expect(subject.validation_errors_for_aru(annual_report_upload).size).to eq(1)
        end
      end
    end
  end

  describe Trade::NumericalityValidationRule do
    describe :validation_errors_for_aru do
      before(:each) do
        sandbox_klass.create(quantity: 'www')
      end
      context 'quantity should be a number' do
        subject do
          create(
            :numericality_validation_rule,
            column_names: [ 'quantity' ],
            is_strict: true
          )
        end
        specify do
          subject.refresh_errors_if_needed(annual_report_upload)
          expect(subject.validation_errors_for_aru(annual_report_upload).size).to eq(1)
        end
      end
    end
  end

  describe Trade::FormatValidationRule do
    describe :validation_errors_for_aru do
      before(:each) do
        sandbox_klass.create(year: '33333')
      end
      context 'year should be a 4 digit value' do
        subject do
          create_year_format_validation
        end
        specify do
          subject.refresh_errors_if_needed(annual_report_upload)
          expect(subject.validation_errors_for_aru(annual_report_upload).size).to eq(1)
        end
      end
    end
  end
end
