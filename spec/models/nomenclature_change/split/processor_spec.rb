require 'spec_helper'

describe NomenclatureChange::Split::Processor do
  include_context 'split_definitions'

  let(:processor){ NomenclatureChange::Split::Processor.new(split) }
  describe :run do
    context "when outputs are existing taxa" do
      let!(:split){ split_with_input_and_output_existing_taxon }
      specify { expect{ processor.run }.not_to change(TaxonConcept, :count) }
      specify { expect{ processor.run }.not_to change(output_species1, :full_name) }
      specify { expect{ processor.run }.not_to change(output_species2, :full_name) }
    end
    context "when output is new taxon" do
      let!(:split){ split_with_input_and_output_new_taxon }
      specify { expect{ processor.run }.to change(TaxonConcept, :count).by(1) }
    end
    context "when output is existing taxon with new status" do
      let(:output_species2){ create_cites_eu_species(:name_status => 'S') }
      let!(:split){ split_with_input_and_outputs_status_change }
      specify { expect{ processor.run }.not_to change(TaxonConcept, :count) }
      specify { expect{ processor.run }.not_to change(output_species1, :full_name) }
      specify { expect{ processor.run }.not_to change(output_species2, :full_name) }
    end
    context "when output is existing taxon with new name" do
      let(:output_species2){ create_cites_eu_subspecies }
      let!(:split){ split_with_input_and_outputs_name_change }
      specify { expect{ processor.run }.to change(TaxonConcept, :count).by(1) }
      specify { expect{ processor.run }.not_to change(output_species1, :full_name) }
      specify { expect{ processor.run }.not_to change(output_species2, :full_name) }
    end
  end
end