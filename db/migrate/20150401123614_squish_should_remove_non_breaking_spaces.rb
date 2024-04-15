class SquishShouldRemoveNonBreakingSpaces < ActiveRecord::Migration[4.2]
  def up
    execute function_sql('20150401123614', 'squish')
  end

  def down
  end
end
