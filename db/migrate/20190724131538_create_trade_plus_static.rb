class CreateTradePlusStatic < ActiveRecord::Migration
  def change
    create_table :trade_plus_static do |t|
      t.string :year
      t.string :appendix
      t.string :taxon_name
      t.integer :taxon_id
      t.string :group_name
      t.string :class_name
      t.string :order_name
      t.string :family_name
      t.string :genus_name
      t.string :importer
      t.string :exporter
      t.string :origin
      t.string :importer_reported_quantity
      t.string :exporter_reported_quantity
      t.string :term
      t.string :term_converted
      t.string :unit
      t.string :unit_converted
      t.string :purpose
      t.string :source
    end
  end
end
