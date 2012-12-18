# == Schema Information
#
# Table name: change_types
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  designation_id :integer          not null
#

class ChangeType < ActiveRecord::Base
  attr_accessible :designation_id, :name
  include Dictionary
  belongs_to :designation

  build_dictionary :addition, :deletion, :reservation, :reservation_withdrawal, :exception
end
