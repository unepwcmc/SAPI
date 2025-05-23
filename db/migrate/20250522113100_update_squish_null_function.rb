class UpdateSquishNullFunction < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      execute function_sql('20250522113100', 'squish_null')
    end
  end

  def down
    safety_assured do
      execute function_sql('20150421071444', 'squish_null')
    end
  end
end
