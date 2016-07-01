shared_context 'name_reassignments_processor_examples' do
  let(:input_species_synonym) {
    create_cites_eu_species(name_status: 'S')
  }
  let(:input_species_synonym_rel) {
    create(:taxon_relationship,
      taxon_relationship_type_id: synonym_relationship_type.id,
      taxon_concept: input_species,
      other_taxon_concept: input_species_synonym
    )
  }
  let(:reassignment) {
    create(:nomenclature_change_name_reassignment,
      input: input,
      reassignable_id: input_species_synonym_rel.id
    )
  }
  let!(:reassignment_target) {
    create(:nomenclature_change_reassignment_target,
      reassignment: reassignment,
      output: output
    )
  }
  before(:each) do
    processor.run
  end
  specify { expect(output_species1.synonyms).to include(input_species_synonym) }
end
