require 'spec_helper'

describe Trade::TaxonConceptSourceValidationRule, :drops_tables => true do
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
  describe :validation_errors do
    context "when species name is from Kingdom Animalia, source_code can't be A" do
      before do
        animal = create(:taxon_concept, :data => {:kingdom_name => 'Animalia'},
                       :taxonomy_id => cites_eu.id)
        sandbox_klass.create(:source_code => 'A', :species_name => animal.full_name)
        sandbox_klass.create(:source_code => 'B', :species_name => animal.full_name)
      end
      subject{
        create(
          :taxon_concept_source_validation_rule,
          :column_names => ['species_name', 'source_code']
        )
      }
      specify{
        subject.validation_errors(annual_report_upload).size.should == 1
      }
    end
    context "when species name is from Kingdom Plantae, source_code can't be C or R" do
      before do
        plant = create(:taxon_concept, :data => {:kingdom_name => 'Plantae'},
                       :taxonomy_id => cites_eu.id)
        sandbox_klass.create(:source_code => 'C', :species_name => plant.full_name)
        sandbox_klass.create(:source_code => 'R', :species_name => plant.full_name)
        sandbox_klass.create(:source_code => 'A', :species_name => plant.full_name)
        sandbox_klass.create(:source_code => 'B', :species_name => plant.full_name)
      end
      subject{
        create(
          :taxon_concept_source_validation_rule,
          :column_names => ['species_name', 'source_code']
        )
      }
      specify{
        subject.validation_errors(annual_report_upload).size.should == 2
      }
    end
  end
end
