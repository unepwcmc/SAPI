# == Schema Information
#
# Table name: trade_codes
#
#  id         :integer          not null, primary key
#  code       :string(255)      not null
#  name_en    :string(255)      not null
#  name_es    :string(255)
#  name_fr    :string(255)
#  type       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_trade_codes_on_code_and_type  (code,type) UNIQUE
#

class Unit < TradeCode
  include Deletable

  validates :code, length: { is: 3 }

  has_many :term_trade_codes_pairs,
    as: :trade_code,
    dependent: :restrict_with_error

  has_many :quotas
  has_many :shipments, class_name: 'Trade::Shipment'

  after_commit :invalidate_controller_action_cache

protected

  def dependent_objects_map
    {
      'quotas' => quotas,
      'shipments' => shipments
    }
  end

private

  def invalidate_controller_action_cache
    Api::V1::UnitsController.invalidate_cache
  end
end
