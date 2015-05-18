class CreateTrimDecimalZeroFunction < ActiveRecord::Migration
  def up
    execute function_sql('20150518161716', 'trim_decimal_zero')
  end

  def down
    execute 'DROP FUNCTION IF EXISTS trim_decimal_zero'
  end
end
