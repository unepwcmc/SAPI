shared_context 'split_definitions' do
  let(:input_species){ create_cites_eu_species }
  let(:output_species1){ create_cites_eu_species }
  let(:output_species2){ create_cites_eu_species }
  let(:output_subspecies2){
    create_cites_eu_subspecies(
      :taxon_name => create(:taxon_name, :scientific_name => 'fatalus'),
      :parent => create_cites_eu_species(
        :taxon_name => create(:taxon_name, :scientific_name => 'fatalus'),
        :parent => create_cites_eu_genus(
          :taxon_name => create(:taxon_name, :scientific_name => 'Errorus')
        )
      )
    )
  }
  let(:split_with_input){
    create(:nomenclature_change_split,
      input_attributes: { taxon_concept_id: input_species.id }
    )
  }
  let(:split_with_input_and_output){
    split_with_input_and_output_existing_taxon
  }
  let(:split_with_input_and_same_output){
    create(:nomenclature_change_split,
      input_attributes: { taxon_concept_id: input_species.id },
      outputs_attributes: {
        0 => { taxon_concept_id: output_species1.id },
        1 => { taxon_concept_id: input_species.id }
      },
      status: NomenclatureChange::Split::OUTPUTS
    )
  }
  let(:split_with_input_and_output_existing_taxon){
    create(:nomenclature_change_split,
      input_attributes: { taxon_concept_id: input_species.id },
      outputs_attributes: {
        0 => { taxon_concept_id: output_species1.id },
        1 => { taxon_concept_id: output_species2.id }
      },
      status: NomenclatureChange::Split::OUTPUTS
    )
  }
  let(:split_with_input_and_output_new_taxon){
    create(:nomenclature_change_split,
      input_attributes: { taxon_concept_id: input_species.id },
      outputs_attributes: {
        0 => { taxon_concept_id: output_species1.id },
        1 => {
          new_scientific_name: 'fatalus',
          :new_parent_id => create_cites_eu_genus(
            :taxon_name => create(:taxon_name, :scientific_name => 'Errorus')
          ).id,
          new_rank_id: species_rank.id,
          new_name_status: 'A'
        }
      },
      status: NomenclatureChange::Split::OUTPUTS
    )
  }
  let(:split_with_input_and_outputs_status_change){
    create(:nomenclature_change_split,
      input_attributes: {taxon_concept_id: input_species.id},
      outputs_attributes: {
        0 => { taxon_concept_id: output_species1.id },
        1 => { taxon_concept_id: output_species2.id, new_name_status: 'A' }
      },
      status: NomenclatureChange::Split::OUTPUTS
    )
  }
  let(:split_with_input_and_outputs_name_change){
    create(:nomenclature_change_split,
      input_attributes: {taxon_concept_id: input_species.id},
      outputs_attributes: {
        0 => { taxon_concept_id: output_species1.id },
        1 => {
          taxon_concept_id: output_subspecies2.id,
          new_scientific_name: 'lolcatus',
          :new_parent_id => create_cites_eu_genus(
            :taxon_name => create(:taxon_name, :scientific_name => 'Errorus')
          ).id,
          new_rank_id: species_rank.id,
          new_name_status: 'A'
        }
      },
      status: NomenclatureChange::Split::OUTPUTS
    )
  }
end
