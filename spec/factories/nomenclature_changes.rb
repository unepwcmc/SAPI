FactoryGirl.define do

  factory :nomenclature_change do
    event
    status 'new'
    type 'NomenclatureChange'

    factory :nomenclature_change_split, class: NomenclatureChange::Split
  end

  factory :nomenclature_change_input, class: NomenclatureChange::Input,
    aliases: [:input] do
    nomenclature_change
    taxon_concept
    note 'Input note'
  end

  factory :nomenclature_change_output, class: NomenclatureChange::Output,
    aliases: [:output] do
    nomenclature_change
    taxon_concept
    note 'Output note'
  end

  factory :nomenclature_change_reassignment, class: NomenclatureChange::Reassignment,
    aliases: [:reassignment] do
    input
    type 'NomenclatureChange::Reassignment'
    reassignable_type 'TaxonConcept'
    note 'Reassignment note'
  end

  factory :nomenclature_change_reassignment_target, class: NomenclatureChange::ReassignmentTarget do
    reassignment
    output
  end

end
