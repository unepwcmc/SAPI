# == Schema Information
#
# Table name: trade_sandbox_template
#
#  id                        :integer          not null, primary key
#  appendix                  :string(255)
#  taxon_name                :string(255)
#  term_code                 :string(255)
#  quantity                  :string(255)
#  unit_code                 :string(255)
#  trading_partner           :string(255)
#  country_of_origin         :string(255)
#  export_permit             :text
#  origin_permit             :text
#  purpose_code              :string(255)
#  source_code               :string(255)
#  year                      :string(255)
#  import_permit             :text
#  reported_taxon_concept_id :integer
#  taxon_concept_id          :integer
#

require 'spec_helper'

describe Trade::SandboxTemplate, :drops_tables => true do
  let(:annual_report_upload) {
    aru = build(:annual_report_upload)
    aru.save(:validate => false)
    aru
  }
  let(:sandbox_klass) {
    Trade::SandboxTemplate.ar_klass(annual_report_upload.sandbox.table_name)
  }
  let(:canis) {
    create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Canis')
    )
  }
  let(:canis_lupus) {
    create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'lupus'),
      :parent => canis
    )
  }
  let(:canis_aureus) {
    create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'aureus'),
      :parent => canis
    )
  }

  describe :update do
    before(:each) do
      @shipment1 = sandbox_klass.create(:taxon_name => canis_lupus.full_name)
    end
    specify {
      @shipment1.update_attributes(:taxon_name => canis_aureus.full_name)
      @shipment1.reload.taxon_concept_id.should == canis_aureus.id
    }
  end

  describe :update_batch do
    before(:each) do
      canis_lupus
      @shipment = sandbox_klass.create(:taxon_name => 'Caniis lupus')
      validation_rule = create_taxon_concept_validation
      @validation_error = create(
        :validation_error,
        annual_report_upload_id: annual_report_upload.id,
        validation_rule_id: validation_rule.id,
        matching_criteria: "{\"taxon_name\": \"Caniis lupus\"}",
        is_ignored: false,
        is_primary: true,
        error_message: "taxon_name Caniis lupus is invalid",
        error_count: 1
      )
    end
    specify {
      @shipment.reload.taxon_concept_id.should be_nil
      sandbox_klass.update_batch(
        { taxon_name: 'Canis lupus' },
        @validation_error,
        annual_report_upload
      )
      @shipment.reload.taxon_concept_id.should == canis_lupus.id
    }
  end

end
