# == Schema Information
#
# Table name: languages
#
#  id         :integer          not null, primary key
#  name_en    :string(255)
#  iso_code1  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name_fr    :string(255)
#  name_es    :string(255)
#

class Language < ActiveRecord::Base
  attr_accessible :iso_code1, :name_en, :name_fr, :name_es
  translates :name

  has_many :common_names
  has_many :annotation_translations

  validates :iso_code1, :presence => true, :uniqueness => true, :length => {:is => 2}

  before_destroy :check_destroy_allowed

  private

  def check_destroy_allowed
    unless can_be_deleted?
      errors.add(:base, "not allowed")
      return false
    end
  end

  def can_be_deleted?
    common_names.count == 0 && annotation_translations.count == 0
  end

end
