require 'spec_helper'

describe Trade::InclusionValidationRule, drops_tables: true do
  describe :validation_errors do
    before(:each) do
      @aru = build(:annual_report_upload)
      @aru.save(validate: false)
      @sandbox_klass = Trade::SandboxTemplate.ar_klass(@aru.sandbox.table_name)
    end

    context 'when W source and country of origin matches distribution' do
      include_context 'Pecari tajacu'
      before(:each) do
        @sandbox_klass.create(
          taxon_name: 'Pecari tajacu', source_code: 'W', country_of_origin: 'AR'
        )
      end
      subject do
        create_taxon_concept_country_of_origin_validation
      end
      specify do
        expect(subject.validation_errors.reload.size).to eq(0)
      end
    end

    context "when W source and country of origin doesn't match distribution" do
      include_context 'Pecari tajacu'
      before(:each) do
        @sandbox_klass.create(
          taxon_name: 'Pecari tajacu', source_code: 'W', country_of_origin: 'PL'
        )
      end
      subject do
        create_taxon_concept_country_of_origin_validation
      end
    end

    context 'when W source and country of origin blank' do
      include_context 'Pecari tajacu'
      before(:each) do
        @sandbox_klass.create(
          taxon_name: 'Pecari tajacu', source_code: 'W', country_of_origin: nil
        )
      end
      subject do
        create_taxon_concept_country_of_origin_validation
      end
      specify do
        expect(subject.validation_errors.reload.size).to eq(0)
      end
    end
  end
end
