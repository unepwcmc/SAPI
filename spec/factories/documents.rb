FactoryGirl.define do

  factory :document do
    sequence(:title) {|n| "Document #{n}"}
    date { Date.today }
    event
  end

end
