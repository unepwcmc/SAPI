shared_context 'lump_definitions' do
  let(:input_species) { create_cites_eu_species }
  let(:input_species1) { input_species }
  let(:input_species2) { create_cites_eu_species }
  let(:output_species) { create_cites_eu_species }
  let(:errorus_genus) do
    create_cites_eu_genus(
      taxon_name: create(:taxon_name, scientific_name: 'Errorus')
    )
  end
  let(:output_subspecies) do
    create_cites_eu_subspecies(
      taxon_name: create(:taxon_name, scientific_name: 'fatalus'),
      parent: create_cites_eu_species(
        taxon_name: create(:taxon_name, scientific_name: 'fatalus'),
        parent: errorus_genus
      )
    )
  end
  let(:lump_with_inputs) do
    create(
      :nomenclature_change_lump,
      inputs_attributes: {
        0 => { taxon_concept_id: input_species1.id },
        1 => { taxon_concept_id: input_species2.id }
      }
    )
  end
  let(:lump_with_inputs_and_output) do
    lump_with_inputs_and_output_existing_taxon
  end
  let(:lump_with_inputs_and_same_output) do
    create(
      :nomenclature_change_lump,
      inputs_attributes: {
        0 => { taxon_concept_id: input_species1.id },
        1 => { taxon_concept_id: input_species2.id }
      },
      output_attributes: {
        taxon_concept_id: input_species1.id
      },
      status: NomenclatureChange::Lump::OUTPUTS
    )
  end
  let(:lump_with_inputs_and_output_existing_taxon) do
    create(
      :nomenclature_change_lump,
      inputs_attributes: {
        0 => { taxon_concept_id: input_species1.id },
        1 => { taxon_concept_id: input_species2.id }
      },
      output_attributes: {
        taxon_concept_id: output_species.id
      },
      status: NomenclatureChange::Lump::OUTPUTS
    )
  end
  let(:lump_with_inputs_and_output_new_taxon) do
    create(
      :nomenclature_change_lump,
      inputs_attributes: {
        0 => { taxon_concept_id: input_species1.id },
        1 => { taxon_concept_id: input_species2.id }
      },
      output_attributes: {
        new_rank_id: output_species.rank_id,
        new_scientific_name: 'fatalus',
        new_parent_id: errorus_genus.id
      },
      status: NomenclatureChange::Lump::OUTPUTS
    )
  end
  let(:lump_with_inputs_and_output_status_change) do
    create(
      :nomenclature_change_lump,
      inputs_attributes: {
        0 => { taxon_concept_id: input_species1.id },
        1 => { taxon_concept_id: input_species2.id }
      },
      output_attributes: {
        taxon_concept_id: output_species.id
      },
      status: NomenclatureChange::Lump::OUTPUTS
    )
  end
  let(:lump_with_inputs_and_output_name_change) do
    create(
      :nomenclature_change_lump,
      inputs_attributes: {
        0 => { taxon_concept_id: input_species1.id },
        1 => { taxon_concept_id: input_species2.id }
      },
      output_attributes: {
        taxon_concept_id: output_subspecies.id,
        new_rank_id: output_species.rank_id,
        new_scientific_name: 'lolcatus',
        new_parent_id: errorus_genus.id
      },
      status: NomenclatureChange::Lump::OUTPUTS
    )
  end
end
