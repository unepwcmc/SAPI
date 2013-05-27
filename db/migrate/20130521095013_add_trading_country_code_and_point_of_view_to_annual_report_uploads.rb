class AddTradingCountryCodeAndPointOfViewToAnnualReportUploads < ActiveRecord::Migration
  def change
    if Rails.env.test?
      add_column :trade_annual_report_uploads, :trading_country_id, :integer, :null => false
    else
      add_column :trade_annual_report_uploads, :trading_country_id, :integer
      any_country = GeoEntity.joins(:geo_entity_type).
          where(:"geo_entity_types.name" => GeoEntityType::COUNTRY).first
      unless any_country
        Trade::AnnualReportUpload.delete_all
      else
        # set to first available country before enforcing a not null constraint
        Trade::AnnualReportUpload.update_all(
          :trading_country_id => any_country.id
        )
      end
      execute 'ALTER TABLE trade_annual_report_uploads ALTER trading_country_id SET NOT NULL'
    end
    add_column :trade_annual_report_uploads, :point_of_view, :string,
      :length => 1, :null => false, :default => 'E'
    add_foreign_key "trade_annual_report_uploads", "geo_entities",
      :name => "trade_annual_report_uploads_trading_country_id_fk",
      :column => "trading_country_id"
  end
end
