# == Schema Information
#
# Table name: trade_permits
#
#  id         :integer          not null, primary key
#  number     :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Trade::Permit < ActiveRecord::Base
  attr_accessible :number
end
