# == Schema Information
#
# Table name: trade_codes
#
#  id             :integer          not null, primary key
#  code           :string(255)      not null
#  name_en        :string(255)      not null
#  description_en :string(255)
#  type           :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  name_es        :string(255)
#  name_fr        :string(255)
#  description_es :string(255)
#  description_fr :string(255)
#

class TradeCode < ActiveRecord::Base
  attr_accessible :code, :type, :name_en, :name_es, :name_fr,
    :description_en, :description_es, :description_fr
  translates :name, :description

  validates :code, :presence => true, :uniqueness => {:scope => :type}

  before_destroy :check_destroy_allowed

  private

  def check_destroy_allowed
    puts "############## before_destroy ####################"
    unless can_be_deleted?
      errors.add(:base, "not allowed")
      return false
    end
  end

  def can_be_deleted?
    false
  end
end
