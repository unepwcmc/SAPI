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
#  export_permit             :string(255)
#  origin_permit             :string(255)
#  purpose_code              :string(255)
#  source_code               :string(255)
#  year                      :string(255)
#  import_permit             :string(255)
#  reported_taxon_concept_id :integer
#  taxon_concept_id          :integer
#

require 'spec_helper'

describe Trade::SandboxTemplate, :drops_tables => true do
  let(:annual_report_upload){
    aru = build(:annual_report_upload)
    aru.save(:validate => false)
    aru
  }
  let(:sandbox_klass){
    Trade::SandboxTemplate.ar_klass(annual_report_upload.sandbox.table_name)
  }
  let(:canis){
    create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Canis')
    )
  }
  let(:canis_lupus){
    create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'lupus'),
      :parent => canis
    )
  }
  let(:canis_aureus){
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
      @shipment1 = sandbox_klass.create(:taxon_name => canis_lupus.full_name)
      @shipment2 = sandbox_klass.create(:taxon_name => canis_aureus.full_name)
    end
    specify {
      sandbox_klass.update_batch(
        {:taxon_name => 'Canis aureus'},
        [@shipment1.id]
      )
      @shipment1.reload.taxon_concept_id.should == canis_aureus.id
    }
  end

end
