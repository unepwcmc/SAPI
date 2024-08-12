shared_context 'document_reassignments_processor_examples' do
  def create_citation(taxon_concepts_ary, geo_entities_ary, document = nil)
    citation = if document.present?
      create(:document_citation, document: document)
    else
      create(:document_citation)
    end
    taxon_concepts_ary.each do |taxon_concept|
      create(
        :document_citation_taxon_concept,
        document_citation: citation,
        taxon_concept: taxon_concept
      )
    end
    geo_entities_ary.each do |geo_entity|
      create(
        :document_citation_geo_entity,
        document_citation: citation,
        geo_entity: geo_entity
      )
    end
    citation
  end

  let!(:citation) { create_citation([ input_species ], [ poland ]) }
  let(:reassignment) do
    create(:nomenclature_change_document_citation_reassignment,
      input: input,
      reassignable_type: 'DocumentCitation',
      reassignable: citation
    )
  end
  let!(:reassignment_target) do
    create(:nomenclature_change_reassignment_target,
      reassignment: reassignment,
      output: output
    )
  end
  let(:poland) do
    create(
      :geo_entity,
      geo_entity_type_id: country_geo_entity_type.id,
      iso_code2: 'PL'
    )
  end

  context 'when output species had no citations in place' do
    before(:each) do
      processor.run
    end
    specify do
      expect(output_species1.document_citation_taxon_concepts.count).to eq(1)
    end
  end
  context 'when output species had an identical citation in place' do
    before(:each) do
      processor.run
    end
    let!(:identical_citation) { create_citation([ input_species ], [ poland ]) }
    specify do
      expect(output_species1.document_citation_taxon_concepts.count).to eq(1)
    end
  end
end
