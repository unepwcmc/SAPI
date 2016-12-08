FactoryGirl.define do

  factory :nomenclature_change do
    event
    status 'new'
    type 'NomenclatureChange'

    factory :nomenclature_change_split, class: NomenclatureChange::Split do
      type 'NomenclatureChange::Split'
    end
    factory :nomenclature_change_lump, class: NomenclatureChange::Lump do
      type 'NomenclatureChange::Lump'
    end
    factory :nomenclature_change_status_swap, class: NomenclatureChange::StatusSwap do
      type 'NomenclatureChange::StatusSwap'
    end
    factory :nomenclature_change_status_to_accepted, class: NomenclatureChange::StatusToAccepted do
      type 'NomenclatureChange::StatusToAccepted'
    end
    factory :nomenclature_change_status_to_synonym, class: NomenclatureChange::StatusToSynonym do
      type 'NomenclatureChange::StatusToSynonym'
    end
  end

  factory :nomenclature_change_input, class: NomenclatureChange::Input,
    aliases: [:input] do
    nomenclature_change
    taxon_concept
  end

  factory :nomenclature_change_output, class: NomenclatureChange::Output,
    aliases: [:output] do
    nomenclature_change
    taxon_concept
  end

  factory :nomenclature_change_reassignment, class: NomenclatureChange::Reassignment,
    aliases: [:reassignment] do
    input
    type 'NomenclatureChange::Reassignment'
    reassignable_type 'TaxonConcept'

    factory :nomenclature_change_parent_reassignment do
      type 'NomenclatureChange::ParentReassignment'
    end
    factory :nomenclature_change_name_reassignment do
      type 'NomenclatureChange::NameReassignment'
      reassignable_type 'TaxonRelationship'
    end
    factory :nomenclature_change_distribution_reassignment do
      type 'NomenclatureChange::DistributionReassignment'
      reassignable_type 'Distribution'
    end
    factory :nomenclature_change_legislation_reassignment do
      type 'NomenclatureChange::LegislationReassignment'
    end
    factory :nomenclature_change_document_citation_reassignment do
      type 'NomenclatureChange::DocumentCitationReassignment'
    end
  end

  factory :nomenclature_change_output_reassignment, class: NomenclatureChange::OutputReassignment,
    aliases: [:output_reassignment] do
    output
    type 'NomenclatureChange::OutputReassignment'
    reassignable_type 'TaxonConcept'

    factory :nomenclature_change_output_parent_reassignment do
      type 'NomenclatureChange::OutputParentReassignment'
    end
    factory :nomenclature_change_output_name_reassignment do
      type 'NomenclatureChange::OutputNameReassignment'
      reassignable_type 'TaxonRelationship'
    end
    factory :nomenclature_change_output_distribution_reassignment do
      type 'NomenclatureChange::OutputDistributionReassignment'
      reassignable_type 'Distribution'
    end
    factory :nomenclature_change_output_legislation_reassignment do
      type 'NomenclatureChange::OutputLegislationReassignment'
    end
  end

  factory :nomenclature_change_reassignment_target, class: NomenclatureChange::ReassignmentTarget do
    reassignment
    output
  end

end
