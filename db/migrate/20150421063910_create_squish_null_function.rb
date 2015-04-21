class CreateSquishNullFunction < ActiveRecord::Migration
  def up
    execute function_sql('20150421071444', 'squish_null')
  end

  def down
  end
end
