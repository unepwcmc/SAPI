class RemoveReportedValuesColumns < ActiveRecord::Migration
  def change
    execute "select * from drop_trade_sandboxes()"
    Trade::AnnualReportUpload.where(:is_done => false).each do |aru|
      aru.destroy
    end
    remove_column :trade_sandbox_template, :reported_appendix
    remove_column :trade_sandbox_template, :reported_species_name
    remove_column :trade_shipments, :reported_appendix
    remove_column :trade_shipments, :reported_species_name
  end
end
