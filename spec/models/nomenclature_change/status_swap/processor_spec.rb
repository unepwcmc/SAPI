require 'spec_helper'

describe NomenclatureChange::StatusSwap::Processor do
  include_context 'status_change_definitions'

  let(:accepted_name) { create_cites_eu_species }

  let(:synonym) {
    tc = create_cites_eu_species(name_status: 'S')
    create(:taxon_relationship,
      taxon_concept: accepted_name,
      other_taxon_concept: tc,
      taxon_relationship_type: synonym_relationship_type
    )
    tc
  }

  before(:each) { synonym_relationship_type }
  let(:processor) { NomenclatureChange::StatusSwap::Processor.new(status_change) }
  let(:primary_output_taxon_concept) { status_change.primary_output.taxon_concept }
  let(:secondary_output_taxon_concept) { status_change.secondary_output.taxon_concept }

  describe :run do
    context "from accepted name" do
      let(:accepted_name_parent) { create_cites_eu_genus }
      let(:accepted_name) { create_cites_eu_species(parent: accepted_name_parent) }
      let(:status_change) { a_to_s_with_swap }
      before(:each) {
        @shipment = create(:shipment,
          taxon_concept: primary_output_taxon_concept,
          reported_taxon_concept: primary_output_taxon_concept
        )
        secondary_output_taxon_concept.create_nomenclature_comment
        processor.run
      }
      specify { expect(primary_output_taxon_concept).to be_is_synonym }
      specify { expect(primary_output_taxon_concept.parent).to eq(accepted_name_parent) }
      specify { expect(secondary_output_taxon_concept.name_status).to eq('A') }
      specify { expect(primary_output_taxon_concept.accepted_names).to include(secondary_output_taxon_concept) }
      specify "public nomenclature note is set" do
        expect(secondary_output_taxon_concept.nomenclature_note_en).to eq(' public')
      end
      specify "internal nomenclature note is set" do
        expect(secondary_output_taxon_concept.nomenclature_comment.try(:note)).to eq(' internal')
      end
    end
  end

  describe :summary do
    let(:status_change) { a_to_s_with_swap }
    specify { expect(processor.summary).to be_kind_of(Array) }
  end
end
