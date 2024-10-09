# == Schema Information
#
# Table name: srg_histories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  tooltip    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class SrgHistory < ApplicationRecord
  # Migrated to controller (Strong Parameters)
  # attr_accessible :name, :tooltip

  has_many :eu_decisions

  validates :name, presence: true, uniqueness: true
end
