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

describe Trade::SpeciesNameAppendixYearValidationRule, :drops_tables => true do
  describe :validation_errors do
    before(:each) do
      @aru = build(:annual_report_upload)
      @aru.save(:validate => false)
      @sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
    end
    include_context 'Loxodonta africana'

    context "when split listing" do
      before do
        Timecop.freeze(Time.local(2012))
      end
      after do
        Timecop.return
      end
      before(:each) do
        @sandbox_klass.create(
          :species_name => 'Loxodonta africana', :appendix => 'I', :year => '2010'
        )
        @sandbox_klass.create(
          :species_name => 'Loxodonta africana', :appendix => 'II', :year => '2010'
        )
      end
      subject{
        create(
          :species_name_appendix_year_validation_rule,
          :column_names => ['species_name', 'appendix', 'year'],
          :valid_values_view => 'valid_species_name_appendix_year_mview'
        )
      }
      specify{
        subject.validation_errors(@aru).size.should == 0
      }
    end
    context "when old listing" do
      before do
        Timecop.freeze(Time.local(1991))
      end
      after do
        Timecop.return
      end
      before(:each) do
        @sandbox_klass.create(
          :species_name => 'Loxodonta africana', :appendix => 'II', :year => '1991'
        )
        @sandbox_klass.create(
          :species_name => 'Loxodonta africana', :appendix => 'I', :year => '1991'
        )
      end
      subject{
        create(:species_name_appendix_year_validation_rule)
      }
      specify{
        subject.validation_errors(@aru).size.should == 1
      }
    end
  end
end
