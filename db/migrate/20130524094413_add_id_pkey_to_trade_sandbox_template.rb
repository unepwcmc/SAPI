class AddIdPkeyToTradeSandboxTemplate < ActiveRecord::Migration
  def change
    execute <<-SQL
      ALTER TABLE trade_sandbox_template ADD COLUMN id BIGSERIAL PRIMARY KEY;
    SQL
  end
end
