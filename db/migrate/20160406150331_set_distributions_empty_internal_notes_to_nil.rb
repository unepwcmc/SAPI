class SetDistributionsEmptyInternalNotesToNil < ActiveRecord::Migration[4.2]
  def change
    ApplicationRecord.connection.execute(
      <<-SQL.squish
        UPDATE distributions
        SET internal_notes=NULL
        WHERE internal_notes=''
      SQL
    )
  end
end
