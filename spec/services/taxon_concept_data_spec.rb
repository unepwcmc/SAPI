require 'spec_helper'

describe TaxonConceptData do

  describe :to_h do
    let(:family) {
      create_cites_eu_family(
        taxon_name: create(:taxon_name, scientific_name: 'Canidae')
      )
    }
    let(:genus) {
      create_cites_eu_genus(
        taxon_name: create(:taxon_name, scientific_name: 'Canis'),
        parent: family
      )
    }
    let(:accepted_species) {
      create_cites_eu_species(parent: genus)
    }
    let(:tcd_to_h) { TaxonConceptData.new(taxon_concept).to_h }
    context "when regular accepted name" do
      let(:taxon_concept) {
        create_cites_eu_subspecies(parent: accepted_species)
      }
      specify { expect(tcd_to_h["family_name"]).to eq('Canidae') }
    end
    context "when N accepted name" do
      let(:taxon_concept) {
        create_cites_eu_subspecies(name_status: 'N', parent: accepted_species)
      }
      specify { expect(tcd_to_h["family_name"]).to eq('Canidae') }
    end
    context "when hybrid" do
      let(:taxon_concept) {
        create_cites_eu_subspecies(name_status: 'H')
      }
      let!(:hybrid_parent_relationship) {
        create(:taxon_relationship,
          taxon_relationship_type: hybrid_relationship_type,
          taxon_concept: accepted_species,
          other_taxon_concept: taxon_concept
        )
      }
      specify { expect(tcd_to_h["family_name"]).to eq('Canidae') }
    end
    context "when synonym" do
      let(:taxon_concept) {
        create_cites_eu_subspecies(name_status: 'S')
      }
      let!(:hybrid_parent_relationship) {
        create(:taxon_relationship,
          taxon_relationship_type: synonym_relationship_type,
          taxon_concept: accepted_species,
          other_taxon_concept: taxon_concept
        )
      }
      specify { expect(tcd_to_h["family_name"]).to eq('Canidae') }
    end
    context "when trade name" do
      let(:taxon_concept) {
        create_cites_eu_subspecies(name_status: 'T')
      }
      let!(:hybrid_parent_relationship) {
        create(:taxon_relationship,
          taxon_relationship_type: trade_name_relationship_type,
          taxon_concept: accepted_species,
          other_taxon_concept: taxon_concept
        )
      }
      specify { expect(tcd_to_h["family_name"]).to eq('Canidae') }
    end
  end

end
