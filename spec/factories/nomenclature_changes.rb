FactoryGirl.define do

  factory :nomenclature_change do
    event
    status 'new'
    type 'NomenclatureChange'

    factory :nomenclature_change_split, class: NomenclatureChange::Split do
      type 'NomenclatureChange::Split'
    end
    factory :nomenclature_change_status_change, class: NomenclatureChange::StatusChange do
      type 'NomenclatureChange::StatusChange'
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
    note 'Reassignment note'

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
  end

  factory :nomenclature_change_reassignment_target, class: NomenclatureChange::ReassignmentTarget do
    reassignment
    output
  end

end
