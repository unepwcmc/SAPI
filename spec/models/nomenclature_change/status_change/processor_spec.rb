require 'spec_helper'

describe NomenclatureChange::StatusChange::Processor do
  include_context 'status_change_definitions'

  before(:each){ synonym_relationship_type }
  let(:processor){ NomenclatureChange::StatusChange::Processor.new(status_change) }
  let(:primary_output_taxon_concept){ status_change.primary_output.taxon_concept }
  let(:secondary_output_taxon_concept){ status_change.secondary_output.taxon_concept }
  describe :run do
    context "when downgrade" do
      let(:status_change){ status_downgrade_with_input_and_secondary_output }
      before(:each){ processor.run }
      specify { expect(primary_output_taxon_concept).to be_is_synonym }
      specify { expect(secondary_output_taxon_concept.name_status).to eq('A') }

      context "when swap" do
        let(:status_change){ status_downgrade_with_swap }
        specify { expect(primary_output_taxon_concept).to be_is_synonym }
        specify { expect(secondary_output_taxon_concept.name_status).to eq('A') }
        specify{ expect(primary_output_taxon_concept.accepted_names).to include(secondary_output_taxon_concept) }
      end
    end
    context "when upgrade" do
      let(:output_species){ secondary_output_taxon_concept }
      let(:status_change){ status_upgrade_with_input }
      before(:each){ processor.run }
      specify { expect(primary_output_taxon_concept.name_status).to eq('A') }

      context "when swap" do
        let(:status_change){ status_upgrade_with_swap }
        specify { expect(primary_output_taxon_concept.name_status).to eq('A') }
        specify { expect(secondary_output_taxon_concept).to be_is_synonym }
        specify{ expect(secondary_output_taxon_concept.accepted_names).to include(primary_output_taxon_concept) }
      end
    end
  end
end