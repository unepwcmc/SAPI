class CreateTradeSandboxTemplate < ActiveRecord::Migration
  def change
    create_table :trade_sandbox_template do |t|
      t.string :appendix_no
      t.string :taxon_check
      t.string :term_code
      t.string :quantity
      t.string :unit_code
      t.string :trading_partner_code
      t.string :origin_country_code
      t.string :export_permit
      t.string :origin_permit
      t.string :purpose_code
      t.string :source_code
      t.string :year

      t.timestamps
    end
  end
end
