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

class Term < TradeCode
  include Deletable

  validates :code, :length => { :is => 3 }

  has_many :trade_restriction_terms
  has_many :eu_decisions
  has_many :shipments, :class_name => 'Trade::Shipment'

  after_commit :expire_controller_action_cache

  protected

  def dependent_objects_map
    {
      'EU decisions' => eu_decisions,
      'trade restrictions' => trade_restriction_terms,
      'shipments' => shipments
    }
  end

  private

  def expire_controller_action_cache
    I18n.available_locales.each do |lang|
      ActionController::Base.new.send(
        :expire_action,
        {
          controller: 'api/v1/terms',
          format: 'json',
          action: 'index',
          locale: lang
        }
      )
    end
  end
end
