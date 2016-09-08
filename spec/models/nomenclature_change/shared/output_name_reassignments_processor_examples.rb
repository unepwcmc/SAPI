shared_context 'output_name_reassignments_processor_examples' do
  let(:output_subspecies2_synonym) {
    create_cites_eu_subspecies(name_status: 'S')
  }
  let(:output_subspecies2_synonym_rel) {
    create(:taxon_relationship,
      taxon_relationship_type_id: synonym_relationship_type.id,
      taxon_concept: output_subspecies2,
      other_taxon_concept: output_subspecies2_synonym
    )
  }
  before(:each) do
    create(:nomenclature_change_output_name_reassignment,
      output: output,
      reassignable: output_subspecies2_synonym_rel
    )
    output_processor.run
    processor.run
  end
  specify { expect(new_output_species.synonyms).to include(output_subspecies2_synonym) }
  specify { expect(old_output_subspecies.synonyms).to be_empty }
end
