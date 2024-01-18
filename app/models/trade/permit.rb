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
  # app/models/trade/shipment.rb is the only place create this record.
  # attr_accessible :number
end
