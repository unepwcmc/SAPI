shared_context 'name_reassignments_processor_examples' do
  let(:input_species_synonym) do
    create_cites_eu_species(name_status: 'S')
  end
  let(:input_species_synonym_rel) do
    create(:taxon_relationship,
      taxon_relationship_type_id: synonym_relationship_type.id,
      taxon_concept: input_species,
      other_taxon_concept: input_species_synonym
    )
  end
  let(:reassignment) do
    create(:nomenclature_change_name_reassignment,
      input: input,
      reassignable_id: input_species_synonym_rel.id
    )
  end
  let!(:reassignment_target) do
    create(:nomenclature_change_reassignment_target,
      reassignment: reassignment,
      output: output
    )
  end
  before(:each) do
    processor.run
  end
  specify { expect(output_species1.synonyms).to include(input_species_synonym) }
end
