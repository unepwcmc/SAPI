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

class Source < TradeCode
  include Deletable

  validates :code, :length => { :is => 1 }

  has_many :trade_restriction_sources
  has_many :eu_decisions
  has_many :shipments, :class_name => 'Trade::Shipment'

  after_commit :invalidate_controller_action_cache

  protected

  def dependent_objects_map
    {
      'EU decisions' => eu_decisions,
      'trade restrictions' => trade_restriction_sources,
      'shipments' => shipments
    }
  end

  private

  def invalidate_controller_action_cache
    Api::V1::SourcesController.invalidate_cache
  end
end
