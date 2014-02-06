require 'spec_helper'

describe Trade::SandboxShipmentsController do
  let(:annual_report_upload){
    aru = build(:annual_report_upload)
    aru.save(:validate => false)
    aru
  }
  let(:sandbox_klass){
    Trade::SandboxTemplate.ar_klass(annual_report_upload.sandbox.table_name)
  }
  describe "PUT update" do
      before(:each) do
        genus = create_cites_eu_genus(
          :taxon_name => create(:taxon_name, :scientific_name => 'Acipenser')
        )
        @species = create_cites_eu_species(
          :taxon_name => create(:taxon_name, :scientific_name => 'baerii'),
          :parent_id => genus.id
        )        
        sandbox_klass.create(:species_name => 'Acipenser baerii')
      end
    it "should return success when species_name not set" do
      s = sandbox_klass.find_by_species_name('Acipenser baerii')
      put :update, :annual_report_upload_id => annual_report_upload.id, 
        :id => s.id, :sandbox_shipment => {:species_name => nil, :accepted_taxon_name => nil}, format: :json
      response.body.should be_blank
    end
    it "should return success when species_name does not exist" do
      s = sandbox_klass.find_by_species_name('Acipenser baerii')
      put :update, :annual_report_upload_id => annual_report_upload.id, 
        :id => s.id, :sandbox_shipment => {:species_name => 'Acipenser foobarus'}, 
        :format => :json
      response.body.should be_blank
    end
  end

end