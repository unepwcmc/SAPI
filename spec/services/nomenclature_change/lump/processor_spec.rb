require 'spec_helper'

describe NomenclatureChange::Lump::Processor do
  include_context 'lump_definitions'

  before(:each) do
    synonym_relationship_type
    @shipment = create(
      :shipment,
      taxon_concept: input_species1,
      reported_taxon_concept: input_species1
    )
  end
  let(:processor) { NomenclatureChange::Lump::Processor.new(lump) }
  describe :run do
    context 'when outputs are existing taxa' do
      let!(:lump) { lump_with_inputs_and_output_existing_taxon }
      specify { expect { processor.run }.not_to change(TaxonConcept, :count) }
      specify { expect { processor.run }.not_to change(output_species, :full_name) }
      context 'relationships and trade' do
        before(:each) { processor.run }
        specify { expect(input_species1.reload).to be_is_synonym }
        specify { expect(input_species1.accepted_names).to include(output_species) }
        specify { expect(input_species1.shipments).to be_empty }
        specify { expect(input_species1.reported_shipments).to include(@shipment) }
        specify { expect(output_species.shipments).to include(@shipment) }
      end
    end
    context 'when output is new taxon' do
      let!(:lump) { lump_with_inputs_and_output_new_taxon }
      specify { expect { processor.run }.to change(TaxonConcept, :count).by(1) }
      context 'relationships and trade' do
        before(:each) { processor.run }
        specify { expect(input_species1.reload).to be_is_synonym }
        specify { expect(input_species1.accepted_names).to include(lump.output.new_taxon_concept) }
        specify { expect(lump.output.new_taxon_concept.shipments).to include(@shipment) }
      end
    end
    context 'when output is existing taxon with new status' do
      let(:output_species2) { create_cites_eu_species(name_status: 'S') }
      let!(:lump) { lump_with_inputs_and_output_status_change }
      specify { expect { processor.run }.not_to change(TaxonConcept, :count) }
      specify { expect { processor.run }.not_to change(output_species, :full_name) }
      context 'relationships and trade' do
        before(:each) { processor.run }
        specify { expect(input_species1.reload).to be_is_synonym }
        specify { expect(input_species1.accepted_names).to include(output_species) }
        specify { expect(output_species.shipments).to include(@shipment) }
      end
    end
    context 'when output is existing taxon with new name' do
      let(:input_genus1) { create_cites_eu_genus }
      let(:input_species1) { create_cites_eu_species(parent: input_genus1) }
      let(:output_species2) { create_cites_eu_subspecies }
      let!(:lump) { lump_with_inputs_and_output_name_change }
      specify { expect { processor.run }.to change(TaxonConcept, :count).by(1) }
      specify { expect { processor.run }.not_to change(output_species, :full_name) }
      context 'relationships and trade' do
        before(:each) { processor.run }
        specify { expect(input_species1.reload).to be_is_synonym }
        specify { expect(input_species1.reload.parent).to eq(input_genus1) }
        specify { expect(input_species1.accepted_names).to include(lump.output.new_taxon_concept) }
        specify { expect(lump.output.new_taxon_concept.shipments).to include(@shipment) }
      end
    end

    context "when input with children that don't change name" do
      let!(:input_species1_child) do
        create_cites_eu_subspecies(parent: input_species1)
      end
      let!(:input_species1_child_listing) do
        create_cites_I_addition(taxon_concept: input_species1_child)
      end
      let(:lump) do
        create(
          :nomenclature_change_lump,
          inputs_attributes: {
            0 => {
              taxon_concept_id: input_species1.id,
              note_en: nil
            },
            1 => {
              taxon_concept_id: input_species2.id,
              note_en: 'input species 2 has been lumped into input species 1'
            }
          },
          output_attributes: {
            taxon_concept_id: input_species1.id,
            note_en: 'input species 1 was lumped from input species 1 and input species 2',
            internal_note: 'output internal note'
          },
          status: NomenclatureChange::Lump::LEGISLATION
        )
      end
      before(:each) { processor.run }
      specify 'input / output species has public nomenclature note set' do
        expect(input_species1.reload.nomenclature_note_en).to eq(' input species 1 was lumped from input species 1 and input species 2')
      end
      specify 'child of input / output species does not inherit public nomenclature note' do
        expect(
          input_species1_child.reload.nomenclature_note_en
        ).to be_nil
      end
      specify 'input / output species has internal nomenclature note set' do
        expect(input_species1.nomenclature_comment.note).to eq(' output internal note')
      end
      specify 'child of input / output species does not inherit internal nomenclature note' do
        expect(
          input_species1_child.nomenclature_comment.try(:note)
        ).to be_nil
      end
      specify 'child of input / output species does not have legislation nomenclature note' do
        expect(
          input_species1_child_listing.nomenclature_note_en
        ).to be_nil
      end
    end

    context 'when input with children that change name' do
      let!(:input_species1_child) do
        create_cites_eu_subspecies(parent: input_species1)
      end
      let!(:input_species1_child_listing) do
        create_cites_I_addition(taxon_concept: input_species1_child)
      end
      let!(:output_species_child) do
        create_cites_eu_subspecies(parent: output_species)
      end
      let(:lump) do
        create(
          :nomenclature_change_lump,
          inputs_attributes: {
            0 => {
              taxon_concept_id: input_species1.id,
              note_en: 'input species 1 has been lumped into output species',
              internal_note: 'input internal note'
            },
            1 => { taxon_concept_id: input_species2.id }
          },
          output_attributes: {
            taxon_concept_id: output_species.id,
            note_en: 'output species was lumped from input species 1 and input species 2',
            internal_note: 'output internal note'
          },
          status: NomenclatureChange::Lump::LEGISLATION
        )
      end
      let(:input) { lump.inputs.first }
      let(:output) { lump.output }
      let(:reassignment) do
        create(
          :nomenclature_change_parent_reassignment,
          input: input,
          reassignable_id: input_species1_child.id
        )
      end
      let!(:reassignment_target) do
        create(
          :nomenclature_change_reassignment_target,
          reassignment: reassignment,
          output: output
        )
      end
      let(:output_species_children) { output_species.children }
      let(:output_species1_child) do
        output_species_children.where.not(id: output_species_child.id).first
      end
      before(:each) { processor.run }
      specify 'input species has public nomenclature note set' do
        expect(input_species1.reload.nomenclature_note_en).to eq(' input species 1 has been lumped into output species')
      end
      specify 'child of input species inherits public nomenclature note' do
        expect(
          input_species1_child.reload.nomenclature_note_en
        ).to eq(input_species1.reload.nomenclature_note_en)
      end
      specify 'input species has internal nomenclature note set' do
        expect(input_species1.nomenclature_comment.note).to eq(' input internal note')
      end
      specify 'child of input species inherits internal nomenclature note' do
        expect(
          input_species1_child.nomenclature_comment.note
        ).to eq(input_species1.nomenclature_comment.note)
      end
      specify 'output species has public nomenclature note set' do
        expect(output_species.reload.nomenclature_note_en).to eq(' output species was lumped from input species 1 and input species 2')
      end
      specify 'child of output species inherits public nomenclature note from input' do
        expect(
          output_species1_child.reload.nomenclature_note_en
        ).to eq(input_species1.reload.nomenclature_note_en)
      end
      specify 'output species has internal nomenclature note set' do
        expect(output_species.nomenclature_comment.note).to eq(' output internal note')
      end
      specify 'child of output species inherits internal nomenclature note from input' do
        expect(
          output_species1_child.nomenclature_comment.note
        ).to eq(input_species1.nomenclature_comment.note)
      end
      specify 'output species child has listing changes from input species child transferred' do
        expect(output_species1_child.listing_changes.count).to eq(1)
      end
      specify 'child of output species has legislation nomenclature note copied from input species' do
        expect(
          output_species1_child.listing_changes.first.nomenclature_note_en
        ).to eq(input_species1.reload.nomenclature_note_en)
      end
      let(:output_species_genus_name) { output_species.parent.full_name }
      specify 'original output species child retains higher taxa intact' do
        expect(output_species_child.data['genus_name']).to eq(output_species_genus_name)
      end
      specify 'new output species child has higher taxa set correctly' do
        expect(output_species1_child.reload.data['genus_name']).to eq(output_species_genus_name)
      end
      specify 'original input species child retains higher taxa intact' do
        expect(input_species1_child.data['genus_name']).to eq(input_species1.parent.full_name)
      end
      specify 'original input species child is a synonym' do
        expect(input_species1_child.reload.name_status).to eq('S')
      end
    end
  end
  context 'when input is genus and parent ressignments occur' do
    let(:input_genus) do
      create_cites_eu_genus(
        taxon_name: create(:taxon_name, scientific_name: 'Crotalus')
      )
    end
    let(:input_genus_child) do
      create_cites_eu_species(
        parent: input_genus,
        taxon_name: create(:taxon_name, scientific_name: 'durissus')
      )
    end
    let!(:input_genus_child_child) do
      create_cites_eu_subspecies(
        parent: input_genus_child,
        taxon_name: create(:taxon_name, scientific_name: 'unicolor')
      )
    end
    let!(:quota) { create(:quota, taxon_concept: input_genus_child, geo_entity: create(:geo_entity)) }
    let!(:document_citation_taxon_concept_input_genus_child) do
      create(:document_citation_taxon_concept, taxon_concept: input_genus_child)
    end
    let(:output_genus) do
      create_cites_eu_genus(
        taxon_name: create(:taxon_name, scientific_name: 'Paracrotalus')
      )
    end
    let(:lump) do
      create(
        :nomenclature_change_lump,
        inputs_attributes: {
          0 => { taxon_concept_id: input_genus.id },
          1 => { taxon_concept_id: output_genus.id }
        },
        output_attributes: { taxon_concept_id: output_genus.id },
        status: NomenclatureChange::Lump::LEGISLATION
      )
    end
    let(:reassignment) do
      create(
        :nomenclature_change_parent_reassignment,
        input: lump.inputs.first,
        reassignable_id: input_genus_child.id
      )
    end
    let!(:reassignment_target) do
      create(
        :nomenclature_change_reassignment_target,
        reassignment: reassignment,
        output: lump.output
      )
    end
    before(:each) { processor.run }
    specify 'input genus child is a synonym' do
      expect(input_genus_child.reload.name_status).to eq('S')
    end
    specify 'input genus child is a synonym of output genus child' do
      output_genus_child = output_genus.children.first
      expect(input_genus_child.accepted_names).to include(output_genus_child)
    end
    specify "input genus child's child is a synonym" do
      expect(input_genus_child_child.reload.name_status).to eq('S')
    end
    specify "input genus child's child's name did not change" do
      expect(input_genus_child_child.reload.full_name).to eq('Crotalus durissus unicolor')
    end
    specify 'output genus should have child with resolved name' do
      output_genus_child = output_genus.children.first
      expect(output_genus_child).not_to be_nil
      expect(output_genus_child.full_name).to eq('Paracrotalus durissus')
    end
    specify 'output genus child should have child with resolved name' do
      output_genus_child = output_genus.children.first
      output_genus_child_child = output_genus_child.children.first
      expect(output_genus_child_child).not_to be_nil
      expect(output_genus_child_child.full_name).to eq('Paracrotalus durissus unicolor')
    end
    specify 'output genus child should have input genus citations' do
      output_genus_child = output_genus.children.first
      expect(output_genus_child.document_citation_taxon_concepts.count).to eq(1)
    end
    specify 'input genus child has no quotas' do
      expect(input_genus_child.quotas).to be_empty
    end
    specify "input genus child's accepted name has 1 quota" do
      output_genus_child = output_genus.children.first
      expect(output_genus_child.quotas.size).to eq(1)
    end
    specify "input genus child's document citations retained" do
      expect(input_genus_child.document_citation_taxon_concepts.count).to eq(1)
    end
  end
  describe :summary do
    let(:lump) { lump_with_inputs_and_output_existing_taxon }
    specify { expect(processor.summary).to be_kind_of(Array) }
  end
end
