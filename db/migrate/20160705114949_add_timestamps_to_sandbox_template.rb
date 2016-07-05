class AddTimestampsToSandboxTemplate < ActiveRecord::Migration
  def up
    add_column :trade_sandbox_template, :created_at, :datetime
    add_column :trade_sandbox_template, :updated_at, :datetime

    execute 'UPDATE trade_sandbox_template SET created_at = NOW(), updated_at = NOW()'

    change_column :trade_sandbox_template, :created_at, :datetime,
      null: false
    execute <<-SQL
      ALTER TABLE "trade_sandbox_template" ALTER COLUMN "created_at"
      SET DEFAULT (NOW() at time zone 'utc')
    SQL
    change_column :trade_sandbox_template, :updated_at, :datetime,
      null: false
    execute <<-SQL
      ALTER TABLE "trade_sandbox_template" ALTER COLUMN "updated_at"
      SET DEFAULT (NOW() at time zone 'utc')
    SQL
  end

  def down
    execute "SELECT * FROM drop_trade_sandbox_views()"
    remove_column :trade_sandbox_template, :created_at
    remove_column :trade_sandbox_template, :updated_at
    execute "SELECT * FROM create_trade_sandbox_views()"
  end
end
