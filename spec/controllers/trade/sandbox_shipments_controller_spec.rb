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
  before(:each) do
    @genus = create_cites_eu_genus(
      :taxon_name => create(:taxon_name, :scientific_name => 'Acipenser')
    )
    @species = create_cites_eu_species(
      :taxon_name => create(:taxon_name, :scientific_name => 'baerii'),
      :parent_id => @genus.id
    )
    @shipment = sandbox_klass.create(:taxon_name => 'Acipenser baerii')
  end
  describe "PUT update" do
    it "should return success when taxon_name not set" do
      put :update, :annual_report_upload_id => annual_report_upload.id,
        :id => @shipment.id,
        :sandbox_shipment => {:taxon_name => nil, :accepted_taxon_name => nil},
        :format => :json
      response.body.should be_blank
    end
    it "should return success when taxon_name does not exist" do
      put :update, :annual_report_upload_id => annual_report_upload.id,
        :id => @shipment.id,
        :sandbox_shipment => {:taxon_name => 'Acipenser foobarus'},
        :format => :json
      response.body.should be_blank
    end
  end

  describe "DELETE destroy" do
    it "should return success" do
      delete :destroy, :annual_report_upload_id => annual_report_upload.id,
        :id => @shipment.id,
        :format => :json
      response.body.should be_blank
    end
  end

  describe "POST update_batch" do
    it "should return success" do
      post :update_batch, :annual_report_upload_id => annual_report_upload.id,
        :filters => {:taxon_concept_id => @species.id},
        :updates => {:taxon_concept_id => @genus.id},
        :format => :json
      response.body.should be_blank
      sandbox_klass.where(:taxon_concept_id => @species.id).count.should == 0
      sandbox_klass.where(:taxon_concept_id => @genus.id).count.should == 1
    end
  end

  describe "POST destroy_batch" do
    it "should return success" do
      post :destroy_batch, :annual_report_upload_id => annual_report_upload.id,
        :filters => {:taxon_concept_id => @species.id},
        :format => :json
      response.body.should be_blank
      sandbox_klass.where(:taxon_concept_id => @species.id).count.should == 0
    end
  end

end