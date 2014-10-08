shared_context 'status_change_definitions' do
  let(:input_species){ create_cites_eu_species }
  let(:status_downgrade_with_primary_output){
    create(:nomenclature_change_status_to_synonym,
      primary_output_attributes: {
        is_primary_output: true,
        taxon_concept_id: input_species.id,
        new_name_status: 'S'
      },
      status: NomenclatureChange::StatusToSynonym::PRIMARY_OUTPUT
    ).reload
  }
  let(:status_upgrade_with_primary_output){
    create(:nomenclature_change_status_to_accepted,
      primary_output_attributes: {
        is_primary_output: true,
        taxon_concept_id: create_cites_eu_species(name_status: 'S').id,
        new_name_status: 'A'
      },
      status: NomenclatureChange::StatusToAccepted::PRIMARY_OUTPUT
    ).reload
  }
  let(:status_downgrade_with_input_and_secondary_output){
    create(:nomenclature_change_status_to_synonym,
      primary_output_attributes: {
        is_primary_output: true,
        taxon_concept_id: input_species.id,
        new_name_status: 'S'
      },
      input_attributes: { taxon_concept_id: input_species.id },
      secondary_output_attributes: {
        is_primary_output: false,
        taxon_concept_id: create_cites_eu_species.id
      },
      status: NomenclatureChange::StatusToSynonym::RELAY
    ).reload
  }
  let(:status_downgrade_with_swap){
    create(:nomenclature_change_status_swap,
      primary_output_attributes: {
        is_primary_output: true,
        taxon_concept_id: create_cites_eu_species.id,
        new_name_status: 'S'
      },
      input_attributes: { taxon_concept_id: input_species.id },
      secondary_output_attributes: {
        is_primary_output: false,
        taxon_concept_id: create_cites_eu_species(name_status: 'S').id,
        new_name_status: 'A'
      },
      status: NomenclatureChange::StatusSwap::SWAP
    ).reload
  }
  let(:status_upgrade_with_input){
    create(:nomenclature_change_status_to_accepted,
      primary_output_attributes: {
        is_primary_output: true,
        taxon_concept_id: create_cites_eu_species(name_status: 'S').id,
        new_name_status: 'A'
      },
      input_attributes: { taxon_concept_id: input_species.id },
      status: NomenclatureChange::StatusToAccepted::RECEIVE
    ).reload
  }
  let(:status_upgrade_with_swap){
    create(:nomenclature_change_status_swap,
      primary_output_attributes: {
        is_primary_output: true,
        taxon_concept_id: create_cites_eu_species(name_status: 'S').id,
        new_name_status: 'A'
      },
      input_attributes: { taxon_concept_id: input_species.id },
      secondary_output_attributes: {
        is_primary_output: false,
        taxon_concept_id: input_species.id,
        new_name_status: 'S'
      },
      status: NomenclatureChange::StatusSwap::SWAP
    ).reload
  }
end