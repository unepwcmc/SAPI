# == Schema Information
#
# Table name: languages
#
#  id         :integer          not null, primary key
#  name_en    :string(255)      not null
#  name_fr    :string(255)
#  name_es    :string(255)
#  iso_code1  :string(255)
#  iso_code3  :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Language < ActiveRecord::Base
  attr_accessible :iso_code1, :iso_code3, :name_en, :name_fr, :name_es
  translates :name

  has_many :common_names

  validates :iso_code1, :uniqueness => true, :length => {:is => 2}, :allow_blank => true
  validates :iso_code3, :presence => true, :uniqueness => true, :length => {:is => 3}

  def can_be_deleted?
    common_names.count == 0
  end

  def self.search query
    if query
      where("UPPER(name_en) LIKE UPPER(:query) OR
        UPPER(name_fr) LIKE UPPER(:query) OR
        UPPER(name_es) LIKE UPPER(:query) OR
        UPPER(iso_code1) LIKE UPPER(:query) OR
        UPPER(iso_code3) LIKE UPPER(:query)",
        :query => "%#{query}%")
    else
      scoped
    end
  end
end
