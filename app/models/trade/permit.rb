# == Schema Information
#
# Table name: trade_permits
#
#  id            :integer          not null, primary key
#  number        :string(255)
#  geo_entity_id :integer
#

class Trade::Permit < ActiveRecord::Base
  attr_accessible :number, :geo_entity_id
end
