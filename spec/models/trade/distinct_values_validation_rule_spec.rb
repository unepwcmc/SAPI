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
#  is_strict         :boolean          default(FALSE), not null
#

require 'spec_helper'

describe Trade::DistinctValuesValidationRule, :drops_tables => true do
  let(:canada) {
    create(
      :geo_entity,
      :geo_entity_type => country_geo_entity_type,
      :name => 'Canada',
      :iso_code2 => 'CA'
    )
  }
  let(:argentina) {
    create(
      :geo_entity,
      :geo_entity_type => country_geo_entity_type,
      :name => 'Argentina',
      :iso_code2 => 'AR'
    )
  }
  describe :validation_errors_for_aru do
    before(:each) do
      @aru = build(:annual_report_upload, :point_of_view => 'E',
        :trading_country_id => canada.id)
      @aru.save(:validate => false)
      @sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
    end
    context 'exporter should not equal importer (E)' do
      before(:each) do
        @sandbox_klass.create(:trading_partner => argentina.iso_code2)
        @sandbox_klass.create(:trading_partner => canada.iso_code2)
      end
      subject {
        create_exporter_importer_validation
      }
      specify {
        subject.refresh_errors_if_needed(@aru)
        subject.validation_errors_for_aru(@aru).size.should == 1
      }
    end
    context 'exporter should not equal importer (I)' do
      before(:each) do
        @aru = build(:annual_report_upload, :point_of_view => 'I',
          :trading_country_id => canada.id)
        @aru.save(:validate => false)
        @sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
        @sandbox_klass.create(:trading_partner => argentina.iso_code2)
        @sandbox_klass.create(:trading_partner => canada.iso_code2)
      end
      subject {
        create_exporter_importer_validation
      }
      specify {
        subject.refresh_errors_if_needed(@aru)
        subject.validation_errors_for_aru(@aru).size.should == 1
      }
    end
    context 'exporter should not equal country of origin' do
      before(:each) do
        @sandbox_klass.create(:country_of_origin => argentina.iso_code2)
        @sandbox_klass.create(:country_of_origin => canada.iso_code2)
      end
      subject {
        create_exporter_country_of_origin_validation
      }
      specify {
        subject.refresh_errors_if_needed(@aru)
        subject.validation_errors_for_aru(@aru).size.should == 1
      }
    end
  end
end
