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

describe Trade::DistinctValuesValidationRule, drops_tables: true do
  let(:canada) do
    create(
      :geo_entity,
      geo_entity_type: country_geo_entity_type,
      name: 'Canada',
      iso_code2: 'CA'
    )
  end
  let(:argentina) do
    create(
      :geo_entity,
      geo_entity_type: country_geo_entity_type,
      name: 'Argentina',
      iso_code2: 'AR'
    )
  end
  describe :validation_errors_for_aru do
    before(:each) do
      @aru = build(
        :annual_report_upload, point_of_view: 'E',
        trading_country_id: canada.id
      )
      @aru.save(validate: false)
      @sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
    end
    context 'exporter should not equal importer (E)' do
      before(:each) do
        @sandbox_klass.create(trading_partner: argentina.iso_code2)
        @sandbox_klass.create(trading_partner: canada.iso_code2)
      end
      subject do
        create_exporter_importer_validation
      end
      specify do
        subject.refresh_errors_if_needed(@aru)
        expect(subject.validation_errors_for_aru(@aru).size).to eq(1)
      end
    end
    context 'exporter should not equal importer (I)' do
      before(:each) do
        @aru = build(
          :annual_report_upload, point_of_view: 'I',
          trading_country_id: canada.id
        )
        @aru.save(validate: false)
        @sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
        @sandbox_klass.create(trading_partner: argentina.iso_code2)
        @sandbox_klass.create(trading_partner: canada.iso_code2)
      end
      subject do
        create_exporter_importer_validation
      end
      specify do
        subject.refresh_errors_if_needed(@aru)
        expect(subject.validation_errors_for_aru(@aru).size).to eq(1)
      end
    end
    context 'exporter should not equal country of origin' do
      before(:each) do
        @sandbox_klass.create(country_of_origin: argentina.iso_code2)
        @sandbox_klass.create(country_of_origin: canada.iso_code2)
      end
      subject do
        create_exporter_country_of_origin_validation
      end
      specify do
        subject.refresh_errors_if_needed(@aru)
        expect(subject.validation_errors_for_aru(@aru).size).to eq(1)
      end
    end
  end
end
