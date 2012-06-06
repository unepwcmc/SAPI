# == Schema Information
#
# Table name: change_types
#
#  id                :integer         not null, primary key
#  listing_change_id :integer
#  name              :string(255)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#

class ChangeType < ActiveRecord::Base
  attr_accessible :listing_change_id, :name
end
