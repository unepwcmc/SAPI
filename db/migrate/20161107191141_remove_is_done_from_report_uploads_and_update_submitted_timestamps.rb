class RemoveIsDoneFromReportUploadsAndUpdateSubmittedTimestamps < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute(
      <<-SQL
        UPDATE trade_annual_report_uploads
        SET submitted_at = updated_at, submitted_by_id = updated_by_id
        WHERE is_done = true
      SQL
    )

    remove_column :trade_annual_report_uploads, :is_done

  end

  def down
    add_column :trade_annual_report_uploads, :is_done, :boolean, default: false

    ActiveRecord::Base.connection.execute(
      <<-SQL
        UPDATE trade_annual_report_uploads
        SET is_done = true
        WHERE submitted_at IS NOT NULL
      SQL
    )
  end
end
