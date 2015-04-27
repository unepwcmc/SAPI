class CreateHigherOrEqualRankNamesFunction < ActiveRecord::Migration
  def up
    execute function_sql('20150402111503', 'higher_or_equal_ranks_names')
  end

  def down
  end
end
