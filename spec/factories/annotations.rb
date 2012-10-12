FactoryGirl.define do

  factory :annotation do
    symbol '#4'
    parent_symbol 'CoP15'
    listing_change
  end

  factory :annotation_translation do
    annotation
    language
    short_note "put me inline"
    full_note "put me in footnote"
  end

end