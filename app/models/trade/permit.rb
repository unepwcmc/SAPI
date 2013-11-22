# == Schema Information
#
# Table name: trade_permits
#
#  id            :integer          not null, primary key
#  number        :string(255)      not null
#  geo_entity_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Trade::Permit < ActiveRecord::Base
  attr_accessible :number, :geo_entity_id
  belongs_to :geo_entity
end
