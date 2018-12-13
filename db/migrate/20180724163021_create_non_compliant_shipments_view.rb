class CreateNonCompliantShipmentsView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS non_compliant_shipments_view"
    execute "CREATE VIEW non_compliant_shipments_view AS #{view_sql('20180724163021', 'non_compliant_shipments_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS non_compliant_shipments_view"
  end
end
