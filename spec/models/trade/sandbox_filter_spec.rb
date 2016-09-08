require 'spec_helper'
describe Trade::SandboxFilter do
  let(:annual_report_upload) {
    aru = build(:annual_report_upload)
    aru.save(:validate => false)
    aru
  }
  let(:sandbox_klass) {
    Trade::SandboxTemplate.ar_klass(annual_report_upload.sandbox.table_name)
  }
  let(:canis_lupus) {
    create_cites_eu_species(
      taxon_name: create(:taxon_name, scientific_name: 'lupus'),
      parent: create_cites_eu_genus(
        taxon_name: create(:taxon_name, scientific_name: 'Canis')
      )
    )
  }
  let(:validation_rule) {
    create_taxon_concept_appendix_year_validation
  }
  before(:each) do
    @shipment1 = sandbox_klass.create(
      taxon_name: canis_lupus.full_name,
      appendix: 'I',
      year: 2016
    )
    @shipment2 = sandbox_klass.create(
      taxon_name: canis_lupus.full_name,
      appendix: 'III',
      year: 2016
    )
    create_cites_I_addition(
      taxon_concept: canis_lupus,
      effective_at: '2010-06-23',
      is_current: true
    )
    create_eu_A_addition(
      taxon_concept: canis_lupus,
      effective_at: '2010-06-23',
      is_current: true,
      event: reg2013
    )
    Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
    @validation_error = create(
      :validation_error,
      annual_report_upload_id: annual_report_upload.id,
      validation_rule_id: validation_rule.id,
      matching_criteria: "{\"taxon_concept_id\": #{canis_lupus.id}, \"appendix\": \"III\", \"year\": 2016}",
      is_ignored: false,
      is_primary: false,
      error_message: "taxon_name Canis lupus with appendix III with year 2016 is invalid",
      error_count: 1
    )
  end

  describe :results do
    subject do
      Trade::SandboxFilter.new(
        annual_report_upload_id: annual_report_upload.id,
        validation_error_id: @validation_error.id
      ).results
    end
    specify { expect(subject).to include(@shipment2) }
    specify { expect(subject).not_to include(@shipment1) }
  end

end
