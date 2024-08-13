shared_context 'status_change_definitions' do
  let(:input_species) { create_cites_eu_species }
  let(:accepted_name) { create_cites_eu_species }
  let(:input_trade_name) do
    tc = create_cites_eu_species(name_status: 'T',
      taxon_name: create(:taxon_name, scientific_name: 'Ridiculus fatalus')
    )
    create(:taxon_relationship,
      taxon_concept: accepted_name,
      other_taxon_concept: tc,
      taxon_relationship_type: trade_name_relationship_type
    )
    tc
  end
  let(:input_trade_name_genus) do
    create_cites_eu_genus(
      taxon_name: create(:taxon_name, scientific_name: 'Ridiculus')
    )
  end
  let(:input_synonym) do
    tc = create_cites_eu_species(name_status: 'S',
      taxon_name: create(:taxon_name, scientific_name: 'Confundus totalus')
    )
    create(:taxon_relationship,
      taxon_concept: accepted_name,
      other_taxon_concept: tc,
      taxon_relationship_type: synonym_relationship_type
    )
    tc
  end
  let(:input_synonym_genus) do
    create_cites_eu_genus(
      taxon_name: create(:taxon_name, scientific_name: 'Confundus')
    )
  end
  let(:n_to_s_with_primary_output) do
    create(:nomenclature_change_status_to_synonym,
      primary_output_attributes: {
        is_primary_output: true,
        taxon_concept_id: input_species.id,
        new_name_status: 'S'
      },
      status: NomenclatureChange::StatusToSynonym::PRIMARY_OUTPUT
    ).reload
  end
  let(:t_to_a_with_primary_output) do
    create(:nomenclature_change_status_to_accepted,
      primary_output_attributes: {
        is_primary_output: true,
        taxon_concept_id: input_trade_name.id,
        new_name_status: 'A',
        new_parent_id: input_trade_name_genus.id
      },
      status: NomenclatureChange::StatusToAccepted::PRIMARY_OUTPUT
    ).reload
  end
  let(:t_to_s_with_primary_and_secondary_output) do
    create(:nomenclature_change_status_to_synonym,
      primary_output_attributes: {
        is_primary_output: true,
        taxon_concept_id: input_trade_name.id,
        new_name_status: 'S'
      },
      secondary_output_attributes: {
        is_primary_output: false,
        taxon_concept_id: accepted_name.id
      },
      status: NomenclatureChange::StatusToSynonym::RELAY
    ).reload
  end
  let(:n_to_s_with_input_and_secondary_output) do
    create(:nomenclature_change_status_to_synonym,
      primary_output_attributes: {
        is_primary_output: true,
        taxon_concept_id: input_species.id,
        new_name_status: 'S'
      },
      input_attributes: { taxon_concept_id: input_species.id },
      secondary_output_attributes: {
        is_primary_output: false,
        taxon_concept_id: accepted_name.id
      },
      status: NomenclatureChange::StatusToSynonym::RELAY
    ).reload
  end
  let(:a_to_s_with_swap_with_primary_output) do
    create(:nomenclature_change_status_swap,
      primary_output_attributes: {
        is_primary_output: true,
        taxon_concept_id: accepted_name.id,
        new_name_status: 'S'
      },
      status: NomenclatureChange::StatusSwap::PRIMARY_OUTPUT
    ).reload
  end
  let(:a_to_s_with_swap) do
    create(:nomenclature_change_status_swap,
      primary_output_attributes: {
        is_primary_output: true,
        taxon_concept_id: accepted_name.id,
        new_name_status: 'S'
      },
      input_attributes: { taxon_concept_id: input_species.id },
      secondary_output_attributes: {
        is_primary_output: false,
        taxon_concept_id: input_synonym.id,
        new_name_status: 'A',
        new_parent_id: input_synonym_genus.id,
        note_en: 'public',
        internal_note: 'internal'
      },
      status: NomenclatureChange::StatusSwap::SECONDARY_OUTPUT
    ).reload
  end
  let(:t_to_a_with_input) do
    create(:nomenclature_change_status_to_accepted,
      primary_output_attributes: {
        is_primary_output: true,
        taxon_concept_id: input_trade_name.id,
        new_name_status: 'A',
        new_parent_id: input_trade_name_genus.id
      },
      status: NomenclatureChange::StatusToAccepted::PRIMARY_OUTPUT
    ).reload
  end
end
