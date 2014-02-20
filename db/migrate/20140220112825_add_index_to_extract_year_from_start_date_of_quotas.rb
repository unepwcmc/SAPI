class AddIndexToExtractYearFromStartDateOfQuotas < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE INDEX trade_restrictions_extract_year_from_start_date
      ON trade_restrictions(EXTRACT(year from start_date))
      WHERE type = 'Quota';
    SQL
  end

  def down
    remove_index :trade_restrictions, "trade_restrictions_extract_year_from_start_date"
  end
end
