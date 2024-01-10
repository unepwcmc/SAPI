require 'spec_helper'

describe Trade::InclusionValidationRule, :drops_tables => true do
  describe :validation_errors do
    before(:each) do
      @aru = build(:annual_report_upload)
      @aru.save(:validate => false)
      @sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
    end

    context "when W source and country of origin matches distribution" do
      include_context 'Pecari tajacu'
      before(:each) do
        @sandbox_klass.create(
          :taxon_name => 'Pecari tajacu', :source_code => 'W', :country_of_origin => 'AR'
        )
      end
      subject {
        create_taxon_concept_country_of_origin_validation
      }
      specify {
        subject.validation_errors(@aru).size.should == 0
      }
    end

    context "when W source and country of origin doesn't match distribution" do
      include_context 'Pecari tajacu'
      before(:each) do
        @sandbox_klass.create(
          :taxon_name => 'Pecari tajacu', :source_code => 'W', :country_of_origin => 'PL'
        )
      end
      subject {
        create_taxon_concept_country_of_origin_validation
      }
    end

    context "when W source and country of origin blank" do
      include_context 'Pecari tajacu'
      before(:each) do
        @sandbox_klass.create(
          :taxon_name => 'Pecari tajacu', :source_code => 'W', :country_of_origin => nil
        )
      end
      subject {
        create_taxon_concept_country_of_origin_validation
      }
      specify {
        subject.validation_errors(@aru).size.should == 0
      }
    end

  end
end
