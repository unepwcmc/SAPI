# == Schema Information
#
# Table name: common_names
#
#  id            :integer          not null, primary key
#  name          :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :integer
#  language_id   :integer          not null
#  updated_by_id :integer
#
# Indexes
#
#  index_common_names_on_created_by_id  (created_by_id)
#  index_common_names_on_language_id    (language_id)
#  index_common_names_on_updated_by_id  (updated_by_id)
#
# Foreign Keys
#
#  common_names_created_by_id_fk  (created_by_id => users.id)
#  common_names_language_id_fk    (language_id => languages.id)
#  common_names_updated_by_id_fk  (updated_by_id => users.id)
#
FactoryBot.define do
  factory :language do
    sequence(:name_en) { |n| "lng#{n}" }
    sequence(:iso_code1) { |n| [ n, n + 1 ].map { |i| (65 + (i % 26)).chr }.join }
    sequence(:iso_code3) { |n| [ n, n + 1, n + 2 ].map { |i| (65 + (i % 26)).chr }.join }
  end

  factory :taxon_common do
    taxon_concept
    common_name
  end

  factory :common_name do
    language
    sequence(:name) { |n| "Honey badger #{n}" }
  end
end
