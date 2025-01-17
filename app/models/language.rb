# == Schema Information
#
# Table name: languages
#
#  id         :integer          not null, primary key
#  iso_code1  :string(255)
#  iso_code3  :string(255)      not null
#  name_en    :string(255)      not null
#  name_es    :string(255)
#  name_fr    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_languages_on_iso_code1  (iso_code1) UNIQUE WHERE (iso_code1 IS NOT NULL)
#  index_languages_on_iso_code3  (iso_code3) UNIQUE
#

class Language < ApplicationRecord
  include Changeable
  include Deletable
  extend Mobility
  # Migrated to controller (Strong Parameters)
  # attr_accessible :iso_code1, :iso_code3, :name_en, :name_fr, :name_es
  translates :name

  has_many :common_names

  validates :iso_code1, uniqueness: true, length: { is: 2 }, allow_blank: true
  validates :iso_code3, presence: true, uniqueness: true, length: { is: 3 }

private

  def dependent_objects_map
    {
      'common names' => common_names
    }
  end
end
