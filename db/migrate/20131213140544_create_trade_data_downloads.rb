class CreateTradeDataDownloads < ActiveRecord::Migration
  def change
    create_table :trade_data_downloads do |t|

      t.string :user_ip
      t.string :report_type
      t.integer :year_from
      t.integer :year_to
      t.string :taxon
      t.string :appendix
      t.string :importer
      t.string :exporter
      t.string :origin
      t.string :term
      t.string :unit
      t.string :source
      t.string :purpose

      t.timestamps
    end
  end
end
