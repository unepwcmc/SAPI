require 'spec_helper'

describe Trade::InclusionValidationRule, :drops_tables => true do
  describe :validation_errors do
    before(:each) do
      @aru = build(:annual_report_upload)
      @aru.save(:validate => false)
      @sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
    end
    include_context 'Pecari tajacu'

    context "when W source and country of origin matches distribution" do
      before(:each) do
        @sandbox_klass.create(
          :species_name => 'Pecari tajacu', :source_code => 'W', :country_of_origin => 'AR'
        )
      end
      subject{
        create(
          :inclusion_validation_rule,
          :scope => {:source_code => 'W'},
          :column_names => ['species_name', 'country_of_origin'],
          :valid_values_view => 'valid_species_name_country_of_origin_view'
        )
      }
      specify{
        subject.validation_errors(@aru).size.should == 0
      }
    end

    context "when W source and country of origin doesn't match distribution" do
      before(:each) do
        @sandbox_klass.create(
          :species_name => 'Pecari tajacu', :source_code => 'W', :country_of_origin => 'PL'
        )
      end
      subject{
        create(
          :inclusion_validation_rule,
          :scope => {:source_code => 'W'},
          :column_names => ['species_name', 'country_of_origin'],
          :valid_values_view => 'valid_species_name_country_of_origin_view'
        )
      }
      specify{
        subject.validation_errors(@aru).size.should == 1
      }
    end

  end
end
