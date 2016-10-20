shared_context 'output_document_reassignments_processor_examples' do
  let(:citation){
    citation = create(
      :document_citation
    )
    create(
      :document_citation_taxon_concept,
      document_citation: citation,
      taxon_concept: old_output_subspecies
    )
    citation
  }
  before(:each) do
    create(:nomenclature_change_output_reassignment,
      output: output,
      reassignable_type: 'DocumentCitation',
      reassignable: citation
    )
    output_processor.run
    processor.run
  end
  specify { expect(new_output_species.document_citation_taxon_concepts.count).to eq(1) }
  specify { expect(old_output_subspecies.document_citation_taxon_concepts).to be_empty }
end