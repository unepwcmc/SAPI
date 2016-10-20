shared_context 'document_reassignments_processor_examples' do
  let(:citation){
    citation = create(
      :document_citation
    )
    create(
      :document_citation_taxon_concept,
      document_citation: citation,
      taxon_concept: input_species
    )
    citation
  }
  let(:reassignment) {
    create(:nomenclature_change_document_citation_reassignment,
      input: input,
      reassignable_type: 'DocumentCitation',
      reassignable: citation
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
  specify { 
    expect(output_species1.document_citation_taxon_concepts.count).to eq(1)
  }
end
