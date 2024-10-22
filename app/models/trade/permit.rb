# == Schema Information
#
# Table name: trade_permits
#
#  id         :integer          not null, primary key
#  number     :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  trade_permits_number_idx        (upper((number)::text) varchar_pattern_ops) UNIQUE
#  trade_permits_number_trigm_idx  (upper((number)::text) gin_trgm_ops) USING gin
#

class Trade::Permit < ApplicationRecord
  # app/models/trade/shipment.rb is the only place create this record.
  # attr_accessible :number
end
