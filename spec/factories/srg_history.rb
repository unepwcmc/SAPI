FactoryGirl.define do
  factory :srg_history do
    sequence(:name) { |n| "srg_history#{n}" }
    tooltip 'asdfasdf'
  end
end
