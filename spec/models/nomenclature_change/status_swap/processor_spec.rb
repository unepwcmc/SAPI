require 'spec_helper'

describe NomenclatureChange::StatusSwap::Processor do
  include_context 'status_change_definitions'

  let(:accepted_name){ create_cites_eu_species }

  let(:synonym){
    tc = create_cites_eu_species(name_status: 'S')
    create(:taxon_relationship,
      taxon_concept: accepted_name,
      other_taxon_concept: tc,
      taxon_relationship_type: synonym_relationship_type
    )
    tc
  }

  before(:each){ synonym_relationship_type }
  let(:processor){ NomenclatureChange::StatusSwap::Processor.new(status_change) }
  let(:primary_output_taxon_concept){ status_change.primary_output.taxon_concept }
  let(:secondary_output_taxon_concept){ status_change.secondary_output.taxon_concept }

  describe :run do
    context "from accepted name" do
      let(:status_change){ status_downgrade_with_swap }
      before(:each){
        @shipment = create(:shipment,
          taxon_concept: primary_output_taxon_concept,
          reported_taxon_concept: primary_output_taxon_concept
        )
        processor.run
      }
      specify{ expect(primary_output_taxon_concept).to be_is_synonym }
      specify{ expect(secondary_output_taxon_concept.name_status).to eq('A') }
      specify{ expect(primary_output_taxon_concept.accepted_names).to include(secondary_output_taxon_concept) }
    end
    context "from synonym" do
      let(:output_species){ secondary_output_taxon_concept }
      let(:status_change){ status_upgrade_with_swap }
      before(:each){
        @shipment = create(:shipment,
          taxon_concept: accepted_name,
          reported_taxon_concept: primary_output_taxon_concept
        )
        processor.run
      }

      specify{ expect(primary_output_taxon_concept.name_status).to eq('A') }
      specify{ expect(secondary_output_taxon_concept).to be_is_synonym }
      specify{ expect(secondary_output_taxon_concept.accepted_names).to include(primary_output_taxon_concept) }
    end
  end


  describe :summary do
    let(:status_change){ status_downgrade_with_input_and_secondary_output }
    specify { expect(processor.summary).to be_kind_of(Array) }
  end
end
