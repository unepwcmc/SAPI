# == Schema Information
#
# Table name: languages
#
#  id           :integer          not null, primary key
#  name_en      :string(255)
#  abbreviation :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  name_fr      :string(255)
#  name_es      :string(255)
#

class Language < ActiveRecord::Base
  attr_accessible :abbreviation, :name_en, :name_fr, :name_es
  translates :name

  validates :abbreviation, :presence => true, :uniqueness => true
end
