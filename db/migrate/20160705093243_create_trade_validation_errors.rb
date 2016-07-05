class CreateTradeValidationErrors < ActiveRecord::Migration
  def up
    create_table :trade_validation_errors do |t|
      t.references :annual_report_upload, null: false
      t.references :validation_rule, null: false
      t.column :matching_criteria, :jsonb, null: false
      t.column :is_ignored, :boolean, default: false
      t.column :is_primary, :boolean, default: false
      t.column :error_message, :text, null: false
      t.column :error_count, :integer, null: false

      t.timestamps
    end
    add_index :trade_validation_errors, :annual_report_upload_id,
      name: :index_trade_validation_errors_on_aru_id
    add_index :trade_validation_errors, :validation_rule_id,
      name: :index_trade_validation_errors_on_vr_id
    execute "CREATE INDEX index_trade_validation_errors_on_matching_criteria
    ON trade_validation_errors USING gin (matching_criteria jsonb_path_ops);"
    execute "CREATE UNIQUE INDEX index_trade_validation_errors_unique
    ON trade_validation_errors (annual_report_upload_id, validation_rule_id, matching_criteria);"
    add_foreign_key :trade_validation_errors, :trade_annual_report_uploads,
      column: :annual_report_upload_id,
      name: :trade_validation_errors_aru_id_fk,
      dependent: :delete
    add_foreign_key :trade_validation_errors, :trade_validation_rules,
      column: :validation_rule_id,
      name: :trade_validation_errors_vr_id_fk,
      dependent: :delete
  end

  def down
    drop_table :trade_validation_errors
  end
end
