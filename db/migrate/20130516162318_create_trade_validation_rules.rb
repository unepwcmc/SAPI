class CreateTradeValidationRules < ActiveRecord::Migration
  def change
    create_table :trade_validation_rules do |t|
      t.string :column_names, :null => false
      t.string :valid_values_view
      t.string :type, :null => false
      t.timestamps
    end
    execute "ALTER TABLE trade_validation_rules ALTER column_names TYPE varchar(255)[] USING string_to_array(column_names, '')"
  end
end
