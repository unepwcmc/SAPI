class FixTrimDecimalZero < ActiveRecord::Migration
  def up
    execute function_sql('20150610111751', 'trim_decimal_zero')
  end

  def down
    execute function_sql('20150518161716', 'trim_decimal_zero')
  end
end
