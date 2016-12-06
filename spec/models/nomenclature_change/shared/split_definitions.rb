shared_context 'split_definitions' do
  let(:genus1) {
    create_cites_eu_genus(
      taxon_name: create(:taxon_name, scientific_name: 'Genus1')
    )
  }
  let(:genus2) {
    create_cites_eu_genus(
      taxon_name: create(:taxon_name, scientific_name: 'Genus2')
    )
  }
  let(:input_species) { create_cites_eu_species(parent: genus1) }
  let(:output_species1) { create_cites_eu_species(parent: genus1) }
  let(:output_species2) { create_cites_eu_species(parent: genus2) }
  let(:errorus_genus) {
    create_cites_eu_genus(
      taxon_name: create(:taxon_name, scientific_name: 'Errorus')
    )
  }
  let(:output_subspecies2) {
    create_cites_eu_subspecies(
      taxon_name: create(:taxon_name, scientific_name: 'fatalus'),
      parent: create_cites_eu_species(
        taxon_name: create(:taxon_name, scientific_name: 'fatalus'),
        parent: errorus_genus
      )
    )
  }
  let(:split_with_input) {
    create(:nomenclature_change_split,
      input_attributes: { taxon_concept_id: input_species.id }
    )
  }
  let(:split_with_input_and_output) {
    split_with_input_and_output_existing_taxon
  }
  let(:split_with_input_and_same_output) {
    create(:nomenclature_change_split,
      input_attributes: { taxon_concept_id: input_species.id },
      outputs_attributes: {
        0 => { taxon_concept_id: output_species1.id },
        1 => { taxon_concept_id: input_species.id }
      },
      status: NomenclatureChange::Split::OUTPUTS
    )
  }
  let(:split_with_input_and_output_existing_taxon) {
    create(:nomenclature_change_split,
      input_attributes: { taxon_concept_id: input_species.id },
      outputs_attributes: {
        0 => { taxon_concept_id: output_species1.id },
        1 => { taxon_concept_id: output_species2.id }
      },
      status: NomenclatureChange::Split::OUTPUTS
    )
  }
  let(:split_with_input_and_output_new_taxon) {
    create(:nomenclature_change_split,
      input_attributes: { taxon_concept_id: input_species.id },
      outputs_attributes: {
        0 => { taxon_concept_id: output_species1.id },
        1 => {
          new_scientific_name: 'fatalus',
          new_parent_id: errorus_genus.id,
          new_rank_id: create(:rank, name: Rank::SPECIES).id,
          new_name_status: 'A'
        }
      },
      status: NomenclatureChange::Split::OUTPUTS
    )
  }
  let(:split_with_input_and_outputs_status_change) {
    create(:nomenclature_change_split,
      input_attributes: { taxon_concept_id: input_species.id },
      outputs_attributes: {
        0 => { taxon_concept_id: output_species1.id },
        1 => {
          taxon_concept_id: output_species2.id,
          new_name_status: 'A',
          new_parent_id: genus2.id
        }
      },
      status: NomenclatureChange::Split::OUTPUTS
    )
  }
  let(:split_with_input_and_outputs_name_change) {
    create(:nomenclature_change_split,
      input_attributes: { taxon_concept_id: input_species.id },
      outputs_attributes: {
        0 => { taxon_concept_id: output_species1.id },
        1 => {
          taxon_concept_id: output_subspecies2.id,
          new_scientific_name: 'lolcatus',
          new_parent_id: errorus_genus.id,
          new_rank_id: create(:rank, name: Rank::SPECIES).id,
          new_name_status: 'A'
        }
      },
      status: NomenclatureChange::Split::OUTPUTS
    )
  }
  let(:split_with_input_with_reassignments) {
    2.times { create(:distribution, taxon_concept: input_species) }
    unreassigned_distribution = create(:distribution, taxon_concept: input_species)
    reassigned_distribution = create(:distribution, taxon_concept: input_species)

    unreassigned_citation = create(:document_citation)
    unreassigned_citation.document_citation_taxon_concepts << create(
      :document_citation_taxon_concept, taxon_concept: input_species
    )
    unreassigned_citation.document_citation_geo_entities << create(
      :document_citation_geo_entity, geo_entity: unreassigned_distribution.geo_entity
    )

    reassigned_citation = create(:document_citation)
    reassigned_citation.document_citation_taxon_concepts << create(
      :document_citation_taxon_concept, taxon_concept: input_species
    )
    reassigned_citation.document_citation_geo_entities << create(
      :document_citation_geo_entity, geo_entity: reassigned_distribution.geo_entity
    )

    2.times { create(:taxon_relationship,
      taxon_concept: input_species,
      other_taxon_concept: create_cites_eu_species(name_status: 'S'),
      taxon_relationship_type: synonym_relationship_type
    )
    }
    name1 = create(:taxon_relationship,
      taxon_concept: input_species,
      other_taxon_concept: create_cites_eu_species(name_status: 'S'),
      taxon_relationship_type: synonym_relationship_type
    )
    name2 = create(:taxon_relationship,
      taxon_concept: input_species,
      other_taxon_concept: create_cites_eu_species(name_status: 'T'),
      taxon_relationship_type: trade_name_relationship_type
    )

    nc = create(:nomenclature_change_split,
      input_attributes: { taxon_concept_id: input_species.id },
      outputs_attributes: {
        0 => { taxon_concept_id: output_species1.id },
        1 => { taxon_concept_id: input_species.id }
      }
    )
    distribution_reassignment = create(:nomenclature_change_distribution_reassignment,
      input: nc.input,
      reassignable: reassigned_distribution
    )
    citation_reassignment = create(:nomenclature_change_document_citation_reassignment,
      input: nc.input,
      reassignable: reassigned_citation
    )
    name_reassignment1 = create(:nomenclature_change_name_reassignment,
      input: nc.input,
      reassignable: name1
    )
    name_reassignment2 = create(:nomenclature_change_name_reassignment,
      input: nc.input,
      reassignable: name2
    )

    create(:nomenclature_change_reassignment_target,
      reassignment: distribution_reassignment,
      output: nc.outputs.last
    )
    create(:nomenclature_change_reassignment_target,
      reassignment: citation_reassignment,
      output: nc.outputs.last
    )
    create(:nomenclature_change_reassignment_target,
      reassignment: name_reassignment1,
      output: nc.outputs.last
    )
    create(:nomenclature_change_reassignment_target,
      reassignment: name_reassignment2,
      output: nc.outputs.last
    )
    nc
  }
end
