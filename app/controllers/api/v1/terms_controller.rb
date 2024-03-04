class Api::V1::TermsController < ApplicationController
  CACHE_KEY_PREFIX = 'terms_with_locale_'

  def index
    cache_key = "#{CACHE_KEY_PREFIX}#{I18n.locale}"

    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      @terms = Term.all.order(:code)

      render :json => @terms,
        :each_serializer => Species::TermSerializer,
        :meta => { :total => @terms.count }
    end
  end

  def self.invalidate_cache
    I18n.available_locales.each do |lang|
      Rails.cache.delete("#{CACHE_KEY_PREFIX}#{lang}")
    end
  end
end
