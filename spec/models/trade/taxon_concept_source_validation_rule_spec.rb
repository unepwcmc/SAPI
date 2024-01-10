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

describe Trade::TaxonConceptSourceValidationRule, :drops_tables => true do
  let(:annual_report_upload) {
    annual_report = build(
      :annual_report_upload,
      :point_of_view => 'E'
    )
    annual_report.save(:validate => false)
    annual_report
  }
  let(:sandbox_klass) {
    Trade::SandboxTemplate.ar_klass(annual_report_upload.sandbox.table_name)
  }
  describe :validation_errors_for_aru do
    context "when species name is from Kingdom Animalia, source_code can't be A" do
      before do
        @animal = create_cites_eu_animal_species
        sandbox_klass.create(:source_code => 'A', :taxon_name => @animal.full_name)
        sandbox_klass.create(:source_code => 'B', :taxon_name => @animal.full_name)
      end
      subject {
        create_taxon_concept_source_validation
      }
      specify {
        subject.refresh_errors_if_needed(annual_report_upload)
        subject.validation_errors_for_aru(annual_report_upload).size.should == 1
      }
      specify {
        subject.refresh_errors_if_needed(annual_report_upload)
        ve = subject.validation_errors_for_aru(annual_report_upload).first
        ve.error_message.should == "taxon_name #{@animal.full_name} with source_code A is invalid"
      }
    end
    context "when species name is from Kingdom Plantae, source_code can't be C or R" do
      before do
        @plant = create_cites_eu_plant_species
        sandbox_klass.create(:source_code => 'C', :taxon_name => @plant.full_name)
        sandbox_klass.create(:source_code => 'R', :taxon_name => @plant.full_name)
        sandbox_klass.create(:source_code => 'A', :taxon_name => @plant.full_name)
        sandbox_klass.create(:source_code => 'B', :taxon_name => @plant.full_name)
      end
      subject {
        create_taxon_concept_source_validation
      }
      specify {
        subject.refresh_errors_if_needed(annual_report_upload)
        subject.validation_errors_for_aru(annual_report_upload).size.should == 2
      }
    end
  end
end
