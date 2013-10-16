require 'spec_helper'

describe Trade::SpeciesNameAppendixYearValidationRule do
  let(:annual_report_upload){
    aru = create(:annual_report_upload)
    aru.save(:validate => false)
    aru
  }
  let(:sandbox_klass){
    Trade::SandboxTemplate.ar_klass(annual_report_upload.sandbox.table_name)
  }
  describe :validation_errors do
    include_context 'Loxodonta africana'

    context "when split listing" do
      before do
        Timecop.freeze(Time.local(2012))
      end
      after do
        Timecop.return
      end
      before(:each) do
        sandbox_klass.delete_all
        sandbox_klass.create(
          :species_name => 'Loxodonta africana', :appendix => 'I', :year => '2010'
        )
        sandbox_klass.create(
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
        subject.validation_errors(annual_report_upload).size.should == 0
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
        sandbox_klass.delete_all
        sandbox_klass.create(
          :species_name => 'Loxodonta africana', :appendix => 'II', :year => '1991'
        )
        sandbox_klass.create(
          :species_name => 'Loxodonta africana', :appendix => 'I', :year => '1991'
        )
      end
      subject{
        create(:species_name_appendix_year_validation_rule)
      }
      specify{
        subject.validation_errors(annual_report_upload).size.should == 1
      }
    end
  end
end