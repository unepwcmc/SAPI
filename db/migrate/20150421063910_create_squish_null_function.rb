class CreateSquishNullFunction < ActiveRecord::Migration[4.2]
  def up
    execute function_sql('20150421071444', 'squish_null')
  end

  def down
  end
end
