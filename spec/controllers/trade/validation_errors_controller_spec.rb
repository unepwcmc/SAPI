require 'spec_helper'

describe Trade::ValidationErrorsController do
  login_admin

  let(:annual_report_upload) {
    aru = build(:annual_report_upload)
    aru.save(:validate => false)
    aru
  }
  let(:sandbox_klass) {
    Trade::SandboxTemplate.ar_klass(annual_report_upload.sandbox.table_name)
  }
  let!(:shipment) {
    sandbox_klass.create(:taxon_name => 'Caniis lupus')
  }
  let(:validation_rule) {
    create_taxon_concept_validation
  }
  let!(:validation_error) {
    create(
      :validation_error,
      annual_report_upload_id: annual_report_upload.id,
      validation_rule_id: validation_rule.id,
      matching_criteria: "{\"taxon_name\": \"Caniis lupus\"}",
      is_ignored: false,
      is_primary: true,
      error_message: "taxon_name Caniis lupus is invalid",
      error_count: 1
    )
  }

  describe "PUT update" do
    it "should update is_ignored" do
      put :update,
        id: validation_error.id,
        validation_error: {
          is_ignored: true
        }
      expect(validation_error.reload.is_ignored).to be_truthy
    end
  end

  describe "GET show" do
    it "should return success" do
      get :show, id: validation_error.id, format: :json
      response.body.should have_json_path('validation_error')
    end
  end

end
