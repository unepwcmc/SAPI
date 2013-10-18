require 'spec_helper'

describe Trade::PovInclusionValidationRule do
  describe :validation_errors do
    include_context 'Pecari tajacu'
    context "when Export and W source and country of origin blank and exporter doesn't match distribution" do
      let(:annual_report_upload){
        aru = build(:annual_report_upload, :point_of_view => 'E', :trading_country_id => canada.id)
        aru.save(:validate => false)
        aru
      }
      let(:sandbox_klass){
        Trade::SandboxTemplate.ar_klass(annual_report_upload.sandbox.table_name)
      }
      before(:each) do
        sandbox_klass.create(
          :species_name => 'Pecari tajacu', :source_code => 'W', :country_of_origin => nil
        )
        sandbox_klass.create(
          :species_name => 'Pecari tajacu', :source_code => 'W', :country_of_origin => argentina.id
        )
      end
      subject{
        create(
          :pov_inclusion_validation_rule,
          :scope => {:point_of_view => 'E', :source_code => 'W', :country_of_origin_blank => true},
          :column_names => ['species_name', 'exporter'],
          :valid_values_view => 'valid_species_name_exporter_view'
        )
      }
      specify{
        subject.validation_errors(annual_report_upload).size.should == 1
      }
    end
    context "when invalid scope specified" do
      let(:annual_report_upload){
        aru = build(:annual_report_upload, :point_of_view => 'E', :trading_country_id => canada.id)
        aru.save(:validate => false)
        aru
      }
      let(:sandbox_klass){
        Trade::SandboxTemplate.ar_klass(annual_report_upload.sandbox.table_name)
      }
      before(:each) do
        sandbox_klass.create(
          :species_name => 'Pecari tajacu', :source_code => 'W', :country_of_origin => nil
        )
      end
      subject{
        create(
          :pov_inclusion_validation_rule,
          :scope => {:point_of_view => 'E', :source_code => 'W', :country_of_originnn_blank => true},
          :column_names => ['species_name', 'exporter'],
          :valid_values_view => 'valid_species_name_exporter_view'
        )
      }
      specify{
        subject.validation_errors(annual_report_upload).size.should == 0
      }
    end
  end
end
