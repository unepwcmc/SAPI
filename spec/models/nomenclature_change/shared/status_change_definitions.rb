shared_context 'status_change_definitions' do
  let(:input_species){ create_cites_eu_species }
  let(:status_downgrade_with_primary_output){
    s = create(:nomenclature_change_status_change)
    create(:nomenclature_change_output, nomenclature_change: s,
      is_primary_output: true,
      taxon_concept_id: create_cites_eu_species.id,
      new_name_status: 'S'
    )
    s.reload
  }
  let(:status_upgrade_with_primary_output){
    s = create(:nomenclature_change_status_change)
    create(:nomenclature_change_output, nomenclature_change: s,
      is_primary_output: true,
      taxon_concept_id: create_cites_eu_species(name_status: 'S').id,
      new_name_status: 'A'
    )
    s.reload
  }
  let(:status_downgrade_with_input){
    s = create(:nomenclature_change_status_change)
    create(:nomenclature_change_output, nomenclature_change: s,
      is_primary_output: true,
      taxon_concept_id: create_cites_eu_species.id,
      new_name_status: 'S'
    )
    create(:nomenclature_change_input, nomenclature_change: s,
      taxon_concept_id: input_species.id
    )
    s
  }
  let(:status_downgrade_with_input_and_secondary_output){
    #input_species = create_cites_eu_species
    s = create(:nomenclature_change_status_change)
    create(:nomenclature_change_output, nomenclature_change: s,
      is_primary_output: true,
      taxon_concept_id: input_species.id,
      new_name_status: 'S'
    )
    create(:nomenclature_change_input, nomenclature_change: s,
      taxon_concept_id: input_species.id
    )
    create(:nomenclature_change_output, nomenclature_change: s,
      is_primary_output: false,
      taxon_concept_id: create_cites_eu_species.id
    )
    s.reload
  }
  let(:status_downgrade_with_swap){
    #input_species = create_cites_eu_species
    s = create(:nomenclature_change_status_change)
    create(:nomenclature_change_output, nomenclature_change: s,
      is_primary_output: true,
      taxon_concept_id: input_species.id,
      new_name_status: 'S'
    )
    create(:nomenclature_change_input, nomenclature_change: s,
      taxon_concept_id: input_species.id
    )
    create(:nomenclature_change_output, nomenclature_change: s,
      is_primary_output: false,
      taxon_concept_id: create_cites_eu_species(name_status: 'S').id,
      new_name_status: 'A'
    )
    s.reload
  }
  let(:status_upgrade_with_input){
    s = create(:nomenclature_change_status_change)
    create(:nomenclature_change_output, nomenclature_change: s,
      is_primary_output: true,
      taxon_concept_id: create_cites_eu_species(name_status: 'S').id,
      new_name_status: 'A'
    )
    create(:nomenclature_change_input, nomenclature_change: s,
      taxon_concept_id: input_species.id
    )
    s.reload
  }
  let(:status_upgrade_with_swap){
    s = create(:nomenclature_change_status_change)
    create(:nomenclature_change_output, nomenclature_change: s,
      is_primary_output: true,
      taxon_concept_id: create_cites_eu_species(name_status: 'S').id,
      new_name_status: 'A'
    )
    create(:nomenclature_change_input, nomenclature_change: s,
      taxon_concept_id: input_species.id
    )
    create(:nomenclature_change_output, nomenclature_change: s,
      is_primary_output: false,
      taxon_concept_id: input_species.id,
      new_name_status: 'S'
    )
    s.reload
  }
end