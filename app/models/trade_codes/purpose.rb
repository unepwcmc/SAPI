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
  validates :code, :length => { :is => 1 }

  has_many :trade_restriction_purposes
  has_many :shipments, :class_name => 'Trade::Shipment'

  protected

  def dependent_objects_map
    {
      'trade restrictions' => trade_restriction_purposes,
      'shipments' => shipments
    }
  end
end
