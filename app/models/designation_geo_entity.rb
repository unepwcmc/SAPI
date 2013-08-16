# == Schema Information
#
# Table name: designation_geo_entities
#
#  id             :integer          not null, primary key
#  designation_id :integer          not null
#  geo_entity_id  :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class DesignationGeoEntity < ActiveRecord::Base
  attr_accessible :designation_id, :geo_entity_id
  belongs_to :designation
end
