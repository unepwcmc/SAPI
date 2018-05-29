require 'spec_helper'

describe Species::ShowTaxonConceptSerializer do
  #At the moment, we need to change the starting date of nomenclature_notification every time
  pending "when species is output of recent nomenclature changes" do
    let(:species) { create_cites_eu_species }
    let(:nomenclature_change) {
      create(:nomenclature_change,
        status: 'submitted',
        created_at: 5.months.ago
      )
    }
    let!(:output) {
      create(:nomenclature_change_output,
        nomenclature_change_id: nomenclature_change.id,
        taxon_concept_id: species.id
      )
    }
    specify {
      expect(described_class.new(species).nomenclature_notification).to eq(true)
    }
  end
  pending "when new species is output of recent nomenclature changes" do
    let(:species) { create_cites_eu_species }
    let(:nomenclature_change) {
      create(:nomenclature_change,
        status: 'submitted',
        created_at: 5.months.ago
      )
    }
    let!(:output) {
      create(:nomenclature_change_output,
        nomenclature_change_id: nomenclature_change.id,
        new_taxon_concept_id: species.id
      )
    }
    specify {
      expect(described_class.new(species).nomenclature_notification).to eq(true)
    }
  end
  context "when species is output of old nomenclature changes" do
    let(:species) { create_cites_eu_species }
    let(:nomenclature_change) {
      create(:nomenclature_change,
        status: 'submitted',
        created_at: 7.months.ago
      )
    }
    let!(:output) {
      create(:nomenclature_change_output,
        nomenclature_change_id: nomenclature_change.id,
        taxon_concept_id: species.id
      )
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
  context "when nomenclature changes is not yet submitted" do
    let(:species) { create_cites_eu_species }
    let(:nomenclature_change) {
      create(:nomenclature_change,
        created_at: 5.months.ago
      )
    }
    let!(:output) {
      create(:nomenclature_change_output,
        nomenclature_change_id: nomenclature_change.id,
        taxon_concept_id: species.id
      )
    }
    specify {
      expect(described_class.new(species).nomenclature_notification).to eq(false)
    }
  end
end
