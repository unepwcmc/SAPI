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
        @animal = create(:taxon_concept, :data => {:kingdom_name => 'Animalia'},
                       :taxonomy_id => cites_eu.id)
        sandbox_klass.create(:source_code => 'A', :taxon_name => @animal.full_name)
        sandbox_klass.create(:source_code => 'B', :taxon_name => @animal.full_name)
      end
      subject{
        create_taxon_concept_source_validation
      }
      specify{
        subject.validation_errors(annual_report_upload).size.should == 1
      }
      specify{
        ve = subject.validation_errors(annual_report_upload).first
        ve.error_selector.should == {'taxon_concept_id' => @animal.id, 'source_code' => 'A'}
        ve.error_message.should == "taxon_name #{@animal.full_name} with source_code A is invalid"
      }
    end
    context "when species name is from Kingdom Plantae, source_code can't be C or R" do
      before do
        @plant = create(:taxon_concept, :data => {:kingdom_name => 'Plantae'},
                       :taxonomy_id => cites_eu.id)
        sandbox_klass.create(:source_code => 'C', :taxon_name => @plant.full_name)
        sandbox_klass.create(:source_code => 'R', :taxon_name => @plant.full_name)
        sandbox_klass.create(:source_code => 'A', :taxon_name => @plant.full_name)
        sandbox_klass.create(:source_code => 'B', :taxon_name => @plant.full_name)
      end
      subject{
        create_taxon_concept_source_validation
      }
      specify{
        subject.validation_errors(annual_report_upload).size.should == 2
      }
      specify{
        ve = subject.validation_errors(annual_report_upload).first
        ve.error_selector['taxon_concept_id'].should == @plant.id
        ve.error_selector['source_code'].should_not be_nil
      }
    end
  end
end
