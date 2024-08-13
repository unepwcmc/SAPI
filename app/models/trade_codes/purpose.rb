# == Schema Information
#
# Table name: trade_codes
#
#  id         :integer          not null, primary key
#  code       :string(255)      not null
#  name_en    :string(255)      not null
#  type       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name_es    :string(255)
#  name_fr    :string(255)
#

class Purpose < TradeCode
  include Deletable

  validates :code, length: { is: 1 }

  has_many :trade_restriction_purposes
  has_many :shipments, class_name: 'Trade::Shipment'

  after_commit :invalidate_controller_action_cache

protected

  def dependent_objects_map
    {
      'trade restrictions' => trade_restriction_purposes,
      'shipments' => shipments
    }
  end

private

  def invalidate_controller_action_cache
    Api::V1::PurposesController.invalidate_cache
  end
end
