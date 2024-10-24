require 'spec_helper'

describe Trade::SandboxShipmentsController do
  login_admin

  let(:annual_report_upload) do
    aru = build(:annual_report_upload)
    aru.save(validate: false)
    aru
  end
  let(:sandbox_klass) do
    Trade::SandboxTemplate.ar_klass(annual_report_upload.sandbox.table_name)
  end
  before(:each) do
    @genus = create_cites_eu_genus(
      taxon_name: create(:taxon_name, scientific_name: 'Acipenser')
    )
    @species = create_cites_eu_species(
      taxon_name: create(:taxon_name, scientific_name: 'baerii'),
      parent_id: @genus.id
    )
    @shipment = sandbox_klass.create(taxon_name: 'Acipenser baerii', appendix: 'I', year: 2016)
    @validation_error = create(
      :validation_error,
      annual_report_upload_id: annual_report_upload.id,
      validation_rule_id: create_taxon_concept_appendix_year_validation.id,
      matching_criteria: { taxon_concept_id: @species.id.to_s, appendix: 'I', year: 2016.to_s },
      is_ignored: false,
      is_primary: false,
      error_message: 'taxon_name Acipenser baerii with appendix I with year 2016 is invalid',
      error_count: 1
    )
  end
  describe 'PUT update' do
    it 'should return success when taxon_name not set' do
      put :update, params: { annual_report_upload_id: annual_report_upload.id, id: @shipment.id, sandbox_shipment: { taxon_name: nil, accepted_taxon_name: nil }, format: :json }
      expect(response.body).to be_blank
    end
    it 'should return success when taxon_name does not exist' do
      put :update, params: { annual_report_upload_id: annual_report_upload.id, id: @shipment.id, sandbox_shipment: { taxon_name: 'Acipenser foobarus' }, format: :json }
      expect(response.body).to be_blank
    end
  end

  describe 'DELETE destroy' do
    it 'should return success' do
      delete :destroy, params: { annual_report_upload_id: annual_report_upload.id, id: @shipment.id, format: :json }
      expect(response.body).to be_blank
    end
  end

  describe 'POST update_batch' do
    it 'should return success' do
      post :update_batch, params: { annual_report_upload_id: annual_report_upload.id, validation_error_id: @validation_error.id, updates: { appendix: 'II' }, format: :json }
      expect(response.body).to be_blank
      expect(sandbox_klass.where(taxon_name: @species.full_name, appendix: 'I').count(true)).to eq(0)
      expect(sandbox_klass.where(taxon_name: @species.full_name, appendix: 'II').count(true)).to eq(1)
    end
  end

  describe 'POST destroy_batch' do
    it 'should return success' do
      post :destroy_batch, params: { annual_report_upload_id: annual_report_upload.id, validation_error_id: @validation_error.id, format: :json }
      expect(response.body).to be_blank
      expect(sandbox_klass.where(taxon_concept_id: @species.id).count(true)).to eq(0)
    end
  end
end
