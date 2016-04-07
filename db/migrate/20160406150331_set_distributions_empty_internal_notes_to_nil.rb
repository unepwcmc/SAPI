class SetDistributionsEmptyInternalNotesToNil < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute(
      <<-SQL
        UPDATE distributions
        SET internal_notes=NULL
        WHERE internal_notes=''
      SQL
    )
  end
end
