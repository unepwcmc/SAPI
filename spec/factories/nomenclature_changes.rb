FactoryGirl.define do

  factory :nomenclature_change do
    event
    status 'new'
    type 'NomenclatureChange'

    factory :nomenclature_change_split, class: NomenclatureChange::Split do
      trait :inputs do
        after(:create) do |split|
          create(:nomenclature_change_input, nomenclature_change: split)
        end
      end
      trait :outputs do
        transient do
          outputs_count 2
        end
        after(:create) do |split, evaluator|
          create_list(:nomenclature_change_output, evaluator.outputs_count, nomenclature_change: split)
        end
      end
      factory :nomenclature_change_split_inputs do
        inputs
        status NomenclatureChange::Split::INPUTS
      end
      factory :nomenclature_change_split_outputs do
        inputs
        outputs
        status NomenclatureChange::Split::OUTPUTS
      end
    end
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
