class Api::V1::UnitsController < ApplicationController
  CACHE_KEY_ALL = 'all_units'

  def index
    @all_rows =
      Rails.cache.fetch(CACHE_KEY_ALL, expires_in: 1.hour) do
        Unit.order(:code).as_json
      end

    render json: @all_rows.map { |row_data| Unit.new(row_data) },
      each_serializer: Species::UnitSerializer,
      meta: { total: @all_rows.count }
  end

  def self.invalidate_cache
    Rails.cache.delete(CACHE_KEY_ALL)
  end
end
