class Api::V1::UnitsController < ApplicationController
  CACHE_KEY_PREFIX = 'units_with_locale_'

  def index
    cache_key = "#{CACHE_KEY_PREFIX}#{I18n.locale}"

    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      @units = Unit.all.order(:code)

      render :json => @units,
        :each_serializer => Species::UnitSerializer,
        :meta => { :total => @units.count }
    end
  end

  def self.invalidate_cache
    I18n.available_locales.each do |lang|
      Rails.cache.delete("#{CACHE_KEY_PREFIX}#{lang}")
    end
  end
end
