shared_context 'lump_definitions' do
  let(:input_species1){ create_cites_eu_species }
  let(:input_species2){ create_cites_eu_species }
  let(:output_species){ create_cites_eu_species }
  let(:lump_with_inputs){
    create(:nomenclature_change_lump,
      :inputs_attributes => {
        0 => {:taxon_concept_id => input_species1.id},
        1 => {:taxon_concept_id => input_species2.id}
      }
    )
  }
  let(:lump_with_inputs_and_output){
    lump_with_inputs_and_output_existing_taxon
  }
  let(:lump_with_inputs_and_same_output){
    create(:nomenclature_change_lump,
      input_attributes: { taxon_concept_id: input_species.id },
      outputs_attributes: {
        0 => { taxon_concept_id: output_species1.id },
        1 => { taxon_concept_id: input_species.id }
      },
      status: NomenclatureChange::Lump::OUTPUTS
    )
  }
  let(:lump_with_inputs_and_output_existing_taxon){
    create(:nomenclature_change_lump,
      :inputs_attributes => {
        0 => {:taxon_concept_id => input_species1.id},
        1 => {:taxon_concept_id => input_species2.id}
      },
      :output_attributes => {:taxon_concept_id => output_species.id},
      status: NomenclatureChange::Lump::OUTPUTS
    )
  }
  let(:lump_with_inputs_and_output_new_taxon){
    create(:nomenclature_change_lump,
      :inputs_attributes => {
        0 => {:taxon_concept_id => input_species1.id},
        1 => {:taxon_concept_id => input_species2.id}
      },
      output_attributes: {
        new_scientific_name: 'fatalus',
        :new_parent_id => create_cites_eu_genus(
          :taxon_name => create(:taxon_name, :scientific_name => 'Errorus')
        ).id,
        new_rank_id: species_rank.id,
        new_name_status: 'A'
      },
      status: NomenclatureChange::Lump::OUTPUTS
    )
  }
  let(:lump_with_inputs_and_output_status_change){
    create(:nomenclature_change_lump,
      :inputs_attributes => {
        0 => {:taxon_concept_id => input_species1.id},
        1 => {:taxon_concept_id => input_species2.id}
      },
      output_attributes: {
        taxon_concept_id: output_species.id,
        new_name_status: 'A'
      },
      status: NomenclatureChange::Lump::OUTPUTS
    )
  }
  let(:lump_with_input_and_outputs_name_change){
    create(:nomenclature_change_lump,
      :inputs_attributes => {
        0 => {:taxon_concept_id => input_species1.id},
        1 => {:taxon_concept_id => input_species2.id}
      },
      output_attributes: {
        taxon_concept_id: output_species.id,
        new_scientific_name: 'lolcatus',
        :new_parent_id => create_cites_eu_genus(
          :taxon_name => create(:taxon_name, :scientific_name => 'Errorus')
        ).id,
        new_rank_id: species_rank.id,
        new_name_status: 'A'
      },
      status: NomenclatureChange::Lump::OUTPUTS
    )
  }
end
