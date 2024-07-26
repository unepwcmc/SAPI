class CreateTradeGroupAndRuleTables < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        create_table :trade_taxon_groups do |t|
          t.string :code, index: { unique: true }
          t.string :name_en
          t.string :name_es
          t.string :name_fr

          t.timestamps
        end

        create_table :trade_conversion_rules do |t|
          t.string :rule_type
          t.string :rule_name
          t.integer :rule_priority
          t.jsonb :rule_input
          t.jsonb :rule_output

          t.timestamps
        end

        add_index :trade_conversion_rules,
          [:rule_type, :rule_priority], unique: true

        safety_assured do
          execute 'DROP VIEW IF EXISTS taxon_trade_taxon_groups_view'
          execute "CREATE VIEW taxon_trade_taxon_groups_view AS #{view_sql('20240725180000', 'taxon_trade_taxon_groups_view')}"
        end
      end

      dir.down do
        safety_assured do
          execute 'DROP VIEW IF EXISTS taxon_trade_taxon_groups_view'
        end

        drop_table :trade_taxon_groups
        drop_table :trade_conversion_rules
      end
    end
  end
end
