class ChangeColumnNamesToMatchNewTemplate < ActiveRecord::Migration
  def change
    change_table(:trade_sandbox_template) do |t|
      #t.rename :appendix_no, :appendix
      t.rename :taxon_check, :species_name
      t.rename :trading_partner_code, :trading_partner
      t.rename :origin_country_code, :country_of_origin
      t.string :import_permit
    end
  end
end
