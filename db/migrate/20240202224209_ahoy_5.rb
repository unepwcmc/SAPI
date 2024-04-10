class Ahoy5 < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    # https://github.com/ankane/ahoy/tree/v5.0.2?tab=readme-ov-file#50
    # before v1.4.0, they named it `visitor_id` instead of `visitor_token`.
    add_index :ahoy_visits, [:visitor_id, :started_at], algorithm: :concurrently
  end
end
