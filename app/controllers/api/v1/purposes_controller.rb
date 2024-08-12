class Api::V1::PurposesController < ApplicationController
  CACHE_KEY_ALL = 'all_purposes'

  def index
    @all_rows = Rails.cache.fetch(CACHE_KEY_ALL, expires_in: 1.hour) do
      Purpose.order(:code).as_json
    end

    render json: @all_rows.map { |row_data| Purpose.new(row_data) },
      each_serializer: Species::PurposeSerializer,
      meta: { total: @all_rows.count }
  end

  def self.invalidate_cache
    Rails.cache.delete(CACHE_KEY_ALL)
  end
end
