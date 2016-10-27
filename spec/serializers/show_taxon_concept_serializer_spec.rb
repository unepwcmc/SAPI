require 'spec_helper'

describe Species::ShowTaxonConceptSerializer do
  context "when species is output of recent nomenclature changes" do
    let(:species) { create_cites_eu_species }
    let!(:output) {
      create(:nomenclature_change_output,
        taxon_concept_id: species.id,
        created_at: 5.months.ago)
    }
    specify {
      expect(described_class.new(species).nomenclature_notification).to eq(true)
    }
  end
  context "when new species is output of recent nomenclature changes" do
    let(:species) { create_cites_eu_species }
    let!(:output) {
      create(:nomenclature_change_output,
        new_taxon_concept_id: species.id,
        created_at: 5.months.ago)
    }
    specify {
      expect(described_class.new(species).nomenclature_notification).to eq(true)
    }
  end
  context "when species is output of old nomenclature changes" do
    let(:species) { create_cites_eu_species }
    let!(:output) {
      create(:nomenclature_change_output,
        taxon_concept_id: species.id,
        created_at: 7.months.ago)
    }
    specify {
      expect(described_class.new(species).nomenclature_notification).to eq(false)
    }
  end
  context "when species is not output of nomenclature changes" do
    let(:species) { create_cites_eu_species }
    specify {
      expect(described_class.new(species).nomenclature_notification).to eq(false)
    }
  end
end
