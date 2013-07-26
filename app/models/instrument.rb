# == Schema Information
#
# Table name: instruments
#
#  id             :integer          not null, primary key
#  designation_id :integer
#  name           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Instrument < ActiveRecord::Base
  attr_accessible :designation_id, :name

  belongs_to :designation
end
