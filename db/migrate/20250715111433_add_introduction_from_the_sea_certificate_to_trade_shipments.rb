##
# Adds:
#
# - `ifs_permit` to `trade_sandbox_template` and all `trade_sandbox_\d+` tables
#   which inherit from the template.
# - `ifs_permit_number` and derived columns `ifs_permit_number`, `ifs_permits_ids` to
#   `trade_shipments`, and all views and matviews which select from it.
#
# Note: after this change, matviews will need to be refreshed. To do this, run
# `Sapi::StoredProcedures.rebuild_compliance_views`. Matviews will error until
# the refresh is complete.
#
# Additionally trade sandbox views will need to be recreated with
# refresh_trade_sandbox_views(). Doing this inside a transaction will probably
# fail due to limits on the number of DDL changes required.

class AddIntroductionFromTheSeaCertificateToTradeShipments <
  ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      ##
      # This cascades to all `trade_sandbox_\d+` tables via postgres inheritance
      # Note that it is ifs_permit, not ifs_permit_number.
      add_column :trade_sandbox_template, :ifs_permit, :text, cascade: true

      reversible do |direction|
        direction.up do
          add_column :trade_shipments, :ifs_permits_ids, :integer,
            array: true,
            null: true
          add_column :trade_shipments, :ifs_permit_number, :text
          add_index :trade_shipments, :ifs_permits_ids,
            using: 'gin',
            name: 'index_trade_shipments_on_ifs_permits_ids'
        end

        direction.down do
          ##
          # NB: this will also remove `index_trade_shipments_on_ifs_permits_ids`
          execute <<-SQL.squish
            ALTER TABLE trade_shipments DROP COLUMN ifs_permits_ids CASCADE;
            ALTER TABLE trade_shipments DROP COLUMN ifs_permit_number CASCADE;
          SQL
        end

        [
          {
            base_name: :trade_shipments_with_taxa,
            down: '20150121111134',
            up: '20150121111134',
            has_mview: true
          },
          {
            base_name: :trade_plus_shipments,
            down: '20200206150700',
            up: '20200206150700'
          },
          {
            base_name: :trade_plus_group,
            down: '20240726120000',
            up: '20240726120000'
          },
          {
            base_name: :trade_plus_formatted_data,
            down: '20241006160000',
            up: '20241006160000'
          },
          {
            base_name: :trade_plus_formatted_data_final,
            down: '20240729120000',
            up: '20240729120000'
          },
          {
            base_name: :trade_plus_complete,
            down: '20240729120000',
            up: '20240729120000',
            has_mview: true
          },
          {
            base_name: :trade_shipments_cites_suspensions,
            down: '2023070616851',
            up: '20250716123123',
            has_mview: true
          },
          {
            base_name: :trade_shipments_mandatory_quotas,
            down: '20210511134942',
            up: '20250716122916',
            has_mview: true
          },
          {
            base_name: :trade_shipments_appendix_i,
            down: '2023070615508',
            up: '20250716113347',
            has_mview: true
          },
          {
            # needs to go at the end, has lots of deps
            base_name: :non_compliant_shipments,
            down: '20180724163021',
            up: '20250716140000'
          }
        ].each do |view_info|
          view_name = "#{view_info[:base_name]}_view"
          view_date = view_info[direction.reverting ? :down : :up]

          # Don't squish, might be comments in the view_sql
          # rubocop:disable Rails/SquishedSQLHeredocs
          execute <<-SQL
            DROP VIEW IF EXISTS "#{view_name}" CASCADE;
            CREATE OR REPLACE VIEW "#{view_name}"
            AS #{view_sql(view_date, view_name.to_s)};
          SQL
          # rubocop:enable Rails/SquishedSQLHeredocs

          if view_info[:has_mview]
            mview_name = "#{view_info[:base_name]}_mview"

            ##
            # WITH NO DATA avoids holding the transaction open for hours; the
            # tradeoff is that querying the matview will error until it can be
            # refreshed.
            execute <<-SQL.squish
              CREATE MATERIALIZED VIEW #{mview_name} AS
              SELECT *
              FROM #{view_name}
              WITH NO DATA;
            SQL
          end
        end

        execute <<-SQL.squish
          SELECT create_trade_plus_complete_mview_indexes();
        SQL
      end
    end
  end
end
