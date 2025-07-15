class AddIntroductionFromTheSeaCertificateToTradeShipments < ActiveRecord::Migration[7.1]
  def change
    # Strong Migrations doesn't like change_table blocks but the Rails linter
    # prefers them, presumably as it means fewer whole-table rewrites.
    safety_assured do
      change_table :trade_sandbox_template, bulk: true, cascade: true do |t|
        t.column :ifs_permit, 'TEXT'
      end

      reversible do |direction|
        direction.up do
          add_column :trade_shipments, :ifs_permits_ids, 'INTEGER[]'
          add_column :trade_shipments, :ifs_permit_number, 'TEXT'
          add_index :trade_shipments, :ifs_permits_ids,
            using: 'gin',
            name: 'index_trade_shipments_on_ifs_permits_ids'
        end

        direction.down do
          # NB: this will also remove the index
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
