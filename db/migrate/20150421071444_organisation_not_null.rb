class OrganisationNotNull < ActiveRecord::Migration
  def up
    execute "UPDATE users SET organisation = 'UNKNOWN' WHERE SQUISH_NULL(organisation) IS NULL"
    change_column :users, :organisation, :text, null: false, default: 'UNKNOWN'
  end

  def down
    change_column :users, :organisation, :text, null: true
    execute "UPDATE users SET organisation = NULL WHERE organisation = 'UNKNOWN'"
  end
end
