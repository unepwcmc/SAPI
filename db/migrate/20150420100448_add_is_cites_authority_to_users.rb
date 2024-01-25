class AddIsCitesAuthorityToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :is_cites_authority, :boolean
    execute 'UPDATE users SET is_cites_authority = false'
    change_column :users, :is_cites_authority, :boolean, null: false, default: false
  end
end
