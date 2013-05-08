FactoryGirl.define do

  factory :trade_annual_report, :class => Trade::AnnualReport do
    geo_entity
    sequence(:year) { |n| n % 10 + 1995 }
  end

end
